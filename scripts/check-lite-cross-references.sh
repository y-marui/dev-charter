#!/usr/bin/env bash
# scripts/charter-manifest.txt で lite 等の配布ブランチにタグ付けされた
# ファイルが、そのタグを持たない（＝該当ブランチに含まれない）ファイルへ
# 相対 Markdown リンクを張っていないかを機械的に検証する。
#
# publish-branch.sh は各ブランチに含まれるファイルだけで src/ を再構築する
# ため、配布先ブランチに存在しないファイルへの相対リンクは常に壊れたリンクに
# なる（full ブランチを指す絶対URLに変更するか、リンク先ファイル自体を同じ
# ブランチへ含める必要がある）。
#
# README.md・README-jp.md・CHARTER_INDEX.md はブランチごとに専用生成される
# ため、リンク先としては常に安全（チェック対象外）。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
MANIFEST="${REPO_ROOT}/scripts/charter-manifest.txt"
SRC="${REPO_ROOT}/src"

trim() {
  sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | { grep -v '^$' || true; }
}

TAG_LINES=$(awk '/^\[tags\]/{f=1;next} f' "$MANIFEST" | trim)

get_tags() {
  echo "$TAG_LINES" | awk -v p="$1" '$1==p {for(i=2;i<=NF;i++) print $i}'
}

has_tag() {
  local path="$1" tag="$2"
  get_tags "$path" | grep -qx "$tag"
}

# base_dir 基準で rel を正規化し、src/ からの相対パスに解決する
resolve() {
  local base_dir="$1" rel="$2"
  rel="${rel%%#*}" # フラグメントを除去
  local combined
  if [ -n "$base_dir" ] && [ "$base_dir" != "." ]; then
    combined="${base_dir}/${rel}"
  else
    combined="$rel"
  fi
  while [[ "$combined" == *"/./"* ]]; do combined="${combined//\/.\//\/}"; done
  combined="${combined#./}"
  while [[ "$combined" == *"/../"* ]]; do
    combined=$(echo "$combined" | sed -E 's#[^/]+/\.\./##')
  done
  combined="${combined#../}"
  echo "$combined"
}

status=0

distributed_files=$(echo "$TAG_LINES" | awk 'NF>1 {print $1}')

while IFS= read -r f; do
  [ -n "$f" ] || continue
  file_path="${SRC}/${f}"
  [ -f "$file_path" ] || continue
  base_dir=$(dirname "$f")

  # `](relative/path.md...)` 形式（http(s) 絶対URLは除外）のリンク先を抽出
  hrefs=$(grep -oE '\]\([^)]+\)' "$file_path" | sed -E 's/^\]\(//; s/\)$//' \
    | grep -E '\.md(#.*)?$' | grep -Ev '^https?://' || true)

  while IFS= read -r href; do
    [ -n "$href" ] || continue
    target=$(resolve "$base_dir" "$href")
    base_target=$(basename "$target")
    case "$base_target" in
      README.md | README-jp.md | CHARTER_INDEX.md) continue ;;
    esac

    for tag in $(get_tags "$f"); do
      if ! has_tag "$target" "$tag"; then
        echo "error: ${f} は '${tag}' に配布されるが、リンク先 ${target}（${href}）は '${tag}' に含まれない。"
        echo "  full ブランチを指す絶対URL（https://github.com/y-marui/dev-charter/blob/full/${target}）に変更するか、"
        echo "  ${target} を scripts/charter-manifest.txt で '${tag}' タグ付けしてください。"
        status=1
      fi
    done
  done <<< "$hrefs"
done <<< "$distributed_files"

exit "$status"
