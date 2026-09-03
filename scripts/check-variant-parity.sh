#!/usr/bin/env bash
# scripts/charter-manifest.txt の <name>-<branch>.md variant 規約
# （フォーマットコメント参照）が、例外（[variant-exceptions]）を除いて
# 正しく守られているかを機械的に検証する。
#
# 1. <name>-<branch>.md が存在するなら、その <branch> タグが [tags] に付いている
#    こと（さもないと配布先ブランチに含まれない）
# 2. branch=full の variant（<name>-full.md）は [full-exclude] に **登録しない**
#    （登録すると full にすら配布されなくなる）。branch=full 以外の variant は
#    必ず [full-exclude] に登録する（さもないと full にも生ファイル名で混入する）
# 3. あるトピックに何らかの variant が1つでもあれば、そのトピックは既知の全
#    branch（マニフェスト中でタグとして使われている全語 + "full"）分の variant
#    を持つこと（例：<name>-lite.md があるのに <name>-full.md が無いのは不整合）
#
# 例外は [variant-exceptions] にトピックのベースパス（<name>.md、branch サフィックス
# を含まない）またはvariantそのもののパスを1行1件で登録する。
#
# 実装メモ: bash 3.2（macOS標準）は `case` を `$(...)` コマンド置換の中に置くと
# パースに失敗する既知の制限があるため、`case` は必ずフォアグラウンドのループで
# 実行し、結果は一時ファイルに書き出してから後続処理に渡す。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
MANIFEST="${REPO_ROOT}/scripts/charter-manifest.txt"
SRC="${REPO_ROOT}/src"

trim() {
  sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | { grep -v '^$' || true; }
}

TAG_LINES=$(awk '/^\[tags\]/{f=1;next} f' "$MANIFEST" | trim)
full_exclude=$(awk '/^\[full-exclude\]/{f=1;next} /^\[tags\]/{f=0} f' "$MANIFEST" | trim | sort -u)
exceptions=$(awk '/^\[variant-exceptions\]/{f=1;next} /^\[/{f=0} f' "$MANIFEST" | trim | sort -u)
known_branches=$( { echo "$TAG_LINES" | awk '{for(i=2;i<=NF;i++) print $i}'; echo full; } | sort -u)

is_exception() { echo "$exceptions" | grep -qx "$1"; }
in_full_exclude() { echo "$full_exclude" | grep -qx "$1"; }

status=0
VARIANTS_FILE=$(mktemp)
trap 'rm -f "$VARIANTS_FILE"' EXIT

# path<TAB>branch<TAB>topic-base（branch サフィックスを外した path）を一時ファイルへ
while IFS= read -r path; do
  [ -n "$path" ] || continue
  dir=$(dirname "$path")
  base=$(basename "$path")
  for b in $known_branches; do
    case "$base" in
      *"-${b}.md")
        stripped="${base%-${b}.md}.md"
        [ "$dir" = "." ] && tbase="$stripped" || tbase="${dir}/${stripped}"
        printf '%s\t%s\t%s\n' "$path" "$b" "$tbase" >> "$VARIANTS_FILE"
        break
        ;;
    esac
  done
done < <(echo "$TAG_LINES" | awk '{print $1}')

if [ ! -s "$VARIANTS_FILE" ]; then
  exit 0
fi

# --- check 1 & 2: full-exclude 登録の正しさ ---
while IFS=$'\t' read -r path branch _tbase; do
  [ -n "$path" ] || continue
  is_exception "$path" && continue
  if [ "$branch" = "full" ]; then
    if in_full_exclude "$path"; then
      echo "error: ${path} は '-full' variant だが [full-exclude] に登録されている（full にすら配布されなくなる）。"
      status=1
    fi
  else
    if ! in_full_exclude "$path"; then
      echo "error: ${path} は '-${branch}' variant だが [full-exclude] に無い（full にも生ファイル名で混入する）。"
      status=1
    fi
  fi
done < "$VARIANTS_FILE"

# --- check 3: トピックごとに既知の全 branch 分の variant が揃っているか ---
topic_bases=$(cut -f3 "$VARIANTS_FILE" | sort -u)
while IFS= read -r tbase; do
  [ -n "$tbase" ] || continue
  is_exception "$tbase" && continue
  dir=$(dirname "$tbase")
  name=$(basename "$tbase" .md)
  for b in $known_branches; do
    [ "$dir" = "." ] && variant_path="${name}-${b}.md" || variant_path="${dir}/${name}-${b}.md"
    if [ ! -f "${SRC}/${variant_path}" ]; then
      echo "error: ${tbase} には variant があるが、'${b}' 用の ${variant_path} が無い（1:1対応していない）。"
      status=1
    fi
  done
done <<< "$topic_bases"

exit "$status"
