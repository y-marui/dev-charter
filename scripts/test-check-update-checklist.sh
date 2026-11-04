#!/usr/bin/env bash
# Tests for src/scripts/check-update-checklist.sh using throwaway repos.
set -euo pipefail

# Run under a git hook, GIT_DIR / GIT_INDEX_FILE etc. point at the outer
# repo; without unsetting them, `git init` / `git config` below would write
# into that repo's shared config. Never touch the outer repo.
while IFS= read -r v; do unset "$v"; done < <(env | sed -n 's/^\(GIT_[A-Z_]*\)=.*/\1/p')
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/dev/null

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/src/scripts/check-update-checklist.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
FAILED=0

new_repo() {
  rm -rf "$TMP/r" && mkdir "$TMP/r" && cd "$TMP/r"
  git init -q -b main
  git config user.email t@example.com && git config user.name t
  git config commit.gpgsign false
  echo a >README.md && git add . && git commit -qm init
  git branch -q base
  git switch -q -c topic
}

touch_file() { mkdir -p "$(dirname "$1")" && echo "$RANDOM" >>"$1" && git add "$1"; }

expect() { # name expected-exit
  local name=$1 want=$2 got=0
  CHARTER_CHECK_BASE=base bash "$SCRIPT" >/dev/null 2>&1 || got=$?
  if [ "$got" -ne "$want" ]; then
    echo "FAIL: $name (want $want, got $got)"; FAILED=1
  else
    echo "ok: $name"
  fi
}

new_repo; expect "empty diff" 0
new_repo; touch_file src/app.py; git commit -qm x; expect "non-charter change" 0
new_repo; touch_file docs/other/a.md; git commit -qm x; expect "docs but not charter" 0
new_repo; touch_file docs/dev-charter/VERSION; git commit -qm x; expect "charter only" 1
new_repo; touch_file docs/dev-charter/VERSION; touch_file AI_CONTEXT.md; git commit -qm x; expect "charter + other file" 0
new_repo; touch_file docs/dev-charter/VERSION; git commit -qm x
git commit -q --allow-empty -m "chore: confirm" -m "Update-Checklist: done"; expect "charter only + trailer" 0
new_repo; touch_file docs/dev-charter/VERSION; git commit -q -m "mention Update-Checklist: done inline"; expect "trailer text mid-line" 1
new_repo; touch_file docs/dev-charter-extra/a.md; git commit -qm x; expect "prefix lookalike dir" 0

exit "$FAILED"
