#!/usr/bin/env bash
# src/CHARTER_INDEX.md に列挙された全ファイルが scripts/charter-manifest.txt の
# [tags] に登録済みかを機械的に検証する。
#
# 新規ドキュメントを CHARTER_INDEX.md に追記した際、どの配布ブランチ（lite 等）
# に含めるかの判断が漏れたまま気づかれずに残ることを防ぐ。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
INDEX="${REPO_ROOT}/src/CHARTER_INDEX.md"
MANIFEST="${REPO_ROOT}/scripts/charter-manifest.txt"

trim() {
  sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | { grep -v '^$' || true; }
}

index_files=$(grep -oE '`[A-Za-z0-9_./-]+\.md`' "$INDEX" | tr -d '`' | sort -u)

tagged_files=$(awk '/^\[tags\]/{f=1;next} f' "$MANIFEST" | trim | awk '{print $1}' | sort -u)
full_exclude=$(awk '/^\[full-exclude\]/{f=1;next} /^\[tags\]/{f=0} f' "$MANIFEST" | trim | sort -u)

status=0

unclassified=$(comm -23 <(echo "$index_files") <(echo "$tagged_files"))
if [ -n "$unclassified" ]; then
  echo "error: src/CHARTER_INDEX.md にあるが scripts/charter-manifest.txt の [tags] に未登録のファイルがあります:"
  echo "$unclassified" | sed 's/^/  - /'
  echo "  scripts/charter-manifest.txt の [tags] に追記してください（タグ無しの行 = full 専用でよい）。"
  status=1
fi

stale=$(comm -13 <(echo "$index_files") <(echo "$tagged_files"))
if [ -n "$stale" ]; then
  echo "error: scripts/charter-manifest.txt の [tags] にあるが src/CHARTER_INDEX.md に存在しないファイルがあります:"
  echo "$stale" | sed 's/^/  - /'
  echo "  scripts/charter-manifest.txt から削除するか、src/CHARTER_INDEX.md を確認してください。"
  status=1
fi

stale_exclude=$(comm -23 <(echo "$full_exclude") <(echo "$tagged_files"))
if [ -n "$stale_exclude" ]; then
  echo "error: scripts/charter-manifest.txt の [full-exclude] にあるが [tags] に存在しないファイルがあります:"
  echo "$stale_exclude" | sed 's/^/  - /'
  status=1
fi

exit "$status"
