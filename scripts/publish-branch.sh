#!/usr/bin/env bash
# scripts/charter-manifest.txt のタグに基づき、配布ブランチ（full・lite・将来
# 追加されるもの）を src/ から構築し、必要な場合のみ push する。
#
# 実際の checkout を経由せず git plumbing（hash-object/update-index/
# write-tree/commit-tree）だけでコミットを組み立てる。
#
# 各ブランチの VERSION は full の VERSION（リポジトリルートの VERSION）とは
# 独立させ、そのブランチに含まれるファイルの内容が実際に変わったときだけ
# 更新する（無関係な変更で採用先に更新PRが飛ぶノイズを防ぐため）。
#
# Usage:
#   scripts/publish-branch.sh <branch>              # 差分があれば origin/<branch> へ push
#   scripts/publish-branch.sh <branch> --dry-run     # 構築結果を表示するだけ。push しない
set -euo pipefail

BRANCH="${1:?usage: publish-branch.sh <branch> [--dry-run]}"
DRY_RUN=0
[ "${2:-}" = "--dry-run" ] && DRY_RUN=1

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

MANIFEST="scripts/charter-manifest.txt"
REMOTE="${CHARTER_REMOTE:-origin}"

trim() {
  sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | { grep -v '^$' || true; }
}

# 実行ビット等のファイルモードを、実ファイルシステムからではなく git の
# 通常のリポジトリインデックスから読む（checkout 先の OS/umask に依存させない
# ため）。この関数の呼び出し時点で GIT_INDEX_FILE は作業用インデックスに
# 差し替え済みのため、一時的に元へ戻して参照する。
mode_of() {
  env -u GIT_INDEX_FILE git ls-files -s "$1" 2>/dev/null | awk '{print $1}'
}

full_exclude=$(awk '/^\[full-exclude\]/{f=1;next} /^\[tags\]/{f=0} f' "$MANIFEST" | trim | sort -u)

if [ "$BRANCH" = "full" ]; then
  include_files=$(awk '/^\[tags\]/{f=1;next} f' "$MANIFEST" | trim | awk '{print $1}' | sort -u)
  if [ -n "$full_exclude" ]; then
    include_files=$(comm -23 <(echo "$include_files") <(echo "$full_exclude"))
  fi
else
  include_files=$(awk '/^\[tags\]/{f=1;next} f' "$MANIFEST" | trim \
    | awk -v b="$BRANCH" '{for(i=2;i<=NF;i++) if ($i==b) {print $1; next}}' | sort -u)
fi

if [ -z "$include_files" ]; then
  echo "error: branch '${BRANCH}' に該当するファイルが ${MANIFEST} にありません。" >&2
  exit 1
fi

# CHARTER_INDEX.md は生の内容をコピーせず、常にブランチ専用に再生成する
include_files=$(echo "$include_files" | grep -v '^CHARTER_INDEX\.md$' || true)

INDEX_FILE=$(mktemp -u)
GEN_CHARTER_INDEX=$(mktemp)
PRE_COMMIT_CONFIG=$(mktemp)
trap 'rm -f "$INDEX_FILE" "$GEN_CHARTER_INDEX" "$PRE_COMMIT_CONFIG"' EXIT
export GIT_INDEX_FILE="$INDEX_FILE"
git read-tree --empty

while IFS= read -r f; do
  [ -n "$f" ] || continue
  blob=$(git hash-object -w "src/${f}")
  git update-index --add --cacheinfo 100644,"$blob","$f"
done <<< "$include_files"

# full にのみ、フックスクリプト一式とセキュリティ設定ファイルをそのまま含める
# （SECURITY_POLICY.md の Setup Steps が docs/dev-charter/ 配下からこれらを
# 前提に取り込むため。lite には含めない — 同ドキュメントの notice 参照）
if [ "$BRANCH" = "full" ]; then
  while IFS= read -r -d '' f; do
    rel="${f#src/}"
    blob=$(git hash-object -w "$f")
    mode=$(mode_of "$f")
    git update-index --add --cacheinfo "${mode:-100644}","$blob","$rel"
  done < <(find src/scripts -type f -print0)

  for f in LICENSE .gitleaks.toml; do
    [ -f "$f" ] || continue
    blob=$(git hash-object -w "$f")
    mode=$(mode_of "$f")
    git update-index --add --cacheinfo "${mode:-100644}","$blob","$f"
  done

  # .pre-commit-config.yaml はこのリポジトリ自身の src/scripts/ レイアウト
  # 前提の entry: パスを持つ。full 配布先では scripts/*（src/ プレフィックス
  # 無し）に平坦化されるため、同梱前にパスを書き換える。
  if [ -f .pre-commit-config.yaml ]; then
    sed -e 's#entry: src/scripts/#entry: scripts/#' \
        -e 's#-File src/scripts/#-File scripts/#' \
        .pre-commit-config.yaml > "$PRE_COMMIT_CONFIG"
    blob=$(git hash-object -w "$PRE_COMMIT_CONFIG")
    mode=$(mode_of .pre-commit-config.yaml)
    git update-index --add --cacheinfo "${mode:-100644}","$blob",.pre-commit-config.yaml
  fi
fi

# ブランチ専用 README（あれば README.md / README-jp.md にリネームして同梱）
for suffix in "" "-jp"; do
  src_readme="src/README-${BRANCH}${suffix}.md"
  if [ -f "$src_readme" ]; then
    blob=$(git hash-object -w "$src_readme")
    readme_name="README${suffix}.md"
    git update-index --add --cacheinfo 100644,"$blob","$readme_name"
  fi
done

# CHARTER_INDEX.md をブランチ用に再生成（マスター版の行から include 対象のみ抽出）
{
  echo "# Charter Index (${BRANCH})"
  sed -n '2,/^## Index/p' src/CHARTER_INDEX.md | sed '$d'
  echo "## Index"
  echo
  echo "| トピック / キーワード | ファイル |"
  echo "|---|---|"
  while IFS= read -r f; do
    grep -F "\`${f}\`" src/CHARTER_INDEX.md || true
  done <<< "$include_files"
} > "$GEN_CHARTER_INDEX"
blob=$(git hash-object -w "$GEN_CHARTER_INDEX")
git update-index --add --cacheinfo 100644,"$blob",CHARTER_INDEX.md

content_tree=$(git write-tree)

parent_sha=$(git ls-remote "$REMOTE" "refs/heads/${BRANCH}" 2>/dev/null | cut -f1 || true)
if [ -n "$parent_sha" ]; then
  parent_tree=$(git rev-parse "${parent_sha}^{tree}")
  # VERSION は毎回値が変わるため、比較対象から除外して純粋な内容差分だけを見る
  parent_content_tree=$(git ls-tree "$parent_tree" | grep -v $'\tVERSION$' | git mktree)
  if [ "$parent_content_tree" = "$content_tree" ]; then
    echo "${BRANCH}: 対象ファイルに変更なし。publish をスキップします。"
    exit 0
  fi
fi

version=$(date -u +%Y-%m-%dT%HZ)
version_blob=$(printf '%s\n' "$version" | git hash-object -w --stdin)
git update-index --add --cacheinfo 100644,"$version_blob",VERSION
final_tree=$(git write-tree)

if [ -n "$parent_sha" ]; then
  commit=$(git commit-tree "$final_tree" -p "$parent_sha" -m "chore: publish ${BRANCH} ${version}")
else
  commit=$(git commit-tree "$final_tree" -m "chore: publish ${BRANCH} ${version}")
fi

if [ "$DRY_RUN" = "1" ]; then
  echo "dry-run: ${commit}（push しません）"
  git show --stat "$commit"
  exit 0
fi

git push "$REMOTE" "${commit}:refs/heads/${BRANCH}"
echo "${BRANCH} branch updated: ${commit} (VERSION ${version})"
