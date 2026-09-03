#!/usr/bin/env bash
# scripts/charter-manifest.txt の <name>-<branch>.md variant 規約
# （フォーマットコメント参照）が、例外（[variant-exceptions]）を除いて
# 正しく1:1で守られているかを機械的に検証する。
#
# <name>-<branch>.md が存在するなら：
#   1. その <branch> タグが [tags] に付いている（さもないと配布先ブランチに
#      含まれない）
#   2. [full-exclude] に登録されている（さもないと full にも生ファイル名の
#      まま混入する）
#   3. 対応する基底ファイル <name>.md が src/ に実在する（さもないと full 側に
#      同トピックが存在しない）
#   4. <name>.md が同じ <branch> タグを重複して持っていない（publish-branch.sh
#      の書き込み順序次第で内容が変わる曖昧な状態を防ぐ）
#
# 逆方向（<name>.md はあるが <name>-<branch>.md が無い）は、そのトピックを
# branch へ配布する必要が無いだけの正常な状態が大半のため、既定では対象外。
# 「本来 branch にも必要なはず」の判断は人間（または AI）のレビュー対象とし、
# scripts/charter-manifest.txt 冒頭のコメントで運用する。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
MANIFEST="${REPO_ROOT}/scripts/charter-manifest.txt"
SRC="${REPO_ROOT}/src"

trim() {
  sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | { grep -v '^$' || true; }
}

TAG_LINES=$(awk '/^\[tags\]/{f=1;next} /^\[full-exclude\]/{f=0} f' "$MANIFEST" | trim)
full_exclude=$(awk '/^\[full-exclude\]/{f=1;next} /^\[tags\]/{f=0} f' "$MANIFEST" | trim | sort -u)
exceptions=$(awk '/^\[variant-exceptions\]/{f=1;next} /^\[/{f=0} f' "$MANIFEST" | trim | sort -u)

get_tags() {
  echo "$TAG_LINES" | awk -v p="$1" '$1==p {for(i=2;i<=NF;i++) print $i}'
}

has_tag() {
  local path="$1" tag="$2"
  get_tags "$path" | grep -qx "$tag"
}

in_full_exclude() {
  echo "$full_exclude" | grep -qx "$1"
}

is_exception() {
  echo "$exceptions" | grep -qx "$1"
}

status=0
all_paths=$(echo "$TAG_LINES" | awk '{print $1}')

while IFS= read -r path; do
  [ -n "$path" ] || continue
  is_exception "$path" && continue

  base_dir=$(dirname "$path")
  base_name=$(basename "$path")

  for tag in $(get_tags "$path"); do
    case "$base_name" in
      *"-${tag}.md")
        variant_base="${base_name%-${tag}.md}.md"
        [ "$base_dir" = "." ] && base_path="$variant_base" || base_path="${base_dir}/${variant_base}"

        if ! in_full_exclude "$path"; then
          echo "error: ${path} は '-${tag}' variant だが [full-exclude] に無い（full にも生ファイル名で混入する）。"
          status=1
        fi

        if [ ! -f "${SRC}/${base_path}" ]; then
          echo "error: ${path} に対応する基底ファイル ${base_path} が src/ に存在しない。"
          status=1
        fi

        if has_tag "$base_path" "$tag"; then
          echo "error: ${base_path} が variant ${path} と同じ '${tag}' タグを重複して持っている（publish-branch.sh の書き込み順序次第で内容が不定になる）。"
          status=1
        fi
        ;;
    esac
  done
done <<< "$all_paths"

exit "$status"
