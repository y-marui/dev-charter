#!/usr/bin/env bash
# dev-charter quick installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh | bash
#
# Environment variables (all optional):
#   CHARTER_REMOTE       git remote name          (default: dev-charter)
#   CHARTER_URL          repository URL           (default: https://github.com/y-marui/dev-charter)
#   CHARTER_PREFIX       install directory        (default: docs/dev-charter)
#   CHARTER_BRANCH       branch to install from   (default: full)
#   CHARTER_UPDATE_ONLY  refuse to fresh-install; only update an existing
#                        install (set to 1). Useful for a Makefile target
#                        that shouldn't silently install `full` the first
#                        time it's run. If nothing is installed yet, prompts
#                        (interactively) or errors out (non-interactively)
#                        instead of picking a branch for you.

set -euo pipefail

REMOTE_NAME="${CHARTER_REMOTE:-dev-charter}"
REMOTE_URL="${CHARTER_URL:-https://github.com/y-marui/dev-charter}"
PREFIX="${CHARTER_PREFIX:-docs/dev-charter}"
BRANCH="${CHARTER_BRANCH:-full}"

# 1. Verify we are inside a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: not in a git repository. Run this script from your project root." >&2
    exit 1
fi

# Prompt the user to launch Claude Code with $1, or print the command to run
# it later. Shared by both the fresh-install and update paths below.
offer_claude_launch() {
    prompt="$1"
    if command -v claude > /dev/null 2>&1; then
        if [ -t 0 ]; then
            printf "Launch Claude Code now to run the setup? [Y/n] "
            read -r answer
            case "${answer:-Y}" in
                [Yy]*|"")
                    exec claude "$prompt"
                    ;;
                *)
                    printf "\nTo start setup later, run:\n"
                    printf "  claude \"%s\"\n" "$prompt"
                    ;;
            esac
        else
            printf "Tip: launch Claude Code to start setup:\n"
            printf "  claude \"%s\"\n" "$prompt"
        fi
    fi
}

# 2. If already installed, update in place instead of installing
if [ -d "$PREFIX" ]; then
    # Detect the already-installed variant from CHARTER_INDEX.md's
    # "# Charter Index (<branch>)" marker instead of trusting CHARTER_BRANCH
    # (defaults to "full"), so re-running this script against an existing
    # lite install without re-passing CHARTER_BRANCH=lite doesn't silently
    # switch it to another variant.
    INSTALLED_BRANCH="full"
    if [ -f "$PREFIX/CHARTER_INDEX.md" ]; then
        MARKER=$(head -1 "$PREFIX/CHARTER_INDEX.md" | grep -oE '\([a-z0-9_-]+\)$' | tr -d '()') || true
        [ -n "$MARKER" ] && INSTALLED_BRANCH="$MARKER"
    fi
    if [ -n "${CHARTER_BRANCH:-}" ] && [ "$CHARTER_BRANCH" != "$INSTALLED_BRANCH" ]; then
        echo "Warning: $PREFIX looks like the '$INSTALLED_BRANCH' variant, but CHARTER_BRANCH=$CHARTER_BRANCH was given." >&2
        echo "  Using '$INSTALLED_BRANCH' (the installed variant) to avoid an accidental full/lite switch." >&2
    fi
    BRANCH="$INSTALLED_BRANCH"

    echo "dev-charter is already installed at $PREFIX ($BRANCH). Updating..."

    if ! git remote get-url "$REMOTE_NAME" > /dev/null 2>&1; then
        echo "Adding remote '$REMOTE_NAME'..."
        git remote add "$REMOTE_NAME" "$REMOTE_URL"
    fi

    echo "Fetching $REMOTE_NAME..."
    git fetch "$REMOTE_NAME"

    # git subtree pull fails on a dirty working tree, so stash first (like
    # the Makefile helper documented in README) and restore afterward.
    STASHED=0
    if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        echo "Stashing uncommitted changes before updating..."
        git stash push -u -m "install.sh update"
        STASHED=1
    fi

    if ! git subtree pull --prefix="$PREFIX" "$REMOTE_NAME" "$BRANCH" --squash \
            -m "chore: update dev-charter to ${REMOTE_NAME}/${BRANCH}"; then
        MERGE_HEAD_PATH=$(git rev-parse --git-path MERGE_HEAD 2>/dev/null || true)
        if [ -n "$MERGE_HEAD_PATH" ] && [ -f "$MERGE_HEAD_PATH" ]; then
            # A real subtree merge is in progress (shared history exists) but
            # its finishing commit was rejected — typically because this
            # project's local scripts/*.sh pre-commit hook copies predate a
            # fix that the incoming update itself carries (e.g. a MERGE_HEAD
            # exemption in check-charter-subtree-edit.sh: the fix that would
            # let this exact commit through only exists in the content the
            # pull is trying to deliver). Resync those hook scripts from the
            # now-staged $PREFIX/scripts/ and finish the SAME merge commit —
            # do NOT fall through to the template-repo fallback below, which
            # would discard shared subtree history unnecessarily.
            echo "git subtree pull's merge commit was rejected (MERGE_HEAD present) — resyncing local hook scripts and retrying..."

            UNMERGED_OUTSIDE_PREFIX=$(git diff --name-only --diff-filter=U | grep -v "^${PREFIX}/" || true)
            if [ -n "$UNMERGED_OUTSIDE_PREFIX" ]; then
                echo "Error: unresolved merge conflicts outside $PREFIX — resolve manually, then commit to finish the merge:" >&2
                while IFS= read -r path; do
                    echo "  $path" >&2
                done <<< "$UNMERGED_OUTSIDE_PREFIX"
                exit 1
            fi

            # $PREFIX is machine-managed (never hand-edited locally, per
            # INSTALL_CHECKLIST.md), so a conflict confined to it is always
            # resolved in favor of the incoming side.
            if [ -n "$(git diff --name-only --diff-filter=U -- "$PREFIX")" ]; then
                git checkout --theirs -- "$PREFIX"
                git add "$PREFIX"
            fi

            for f in scripts/*.sh scripts/*.ps1; do
                [ -e "$f" ] || continue
                INCOMING="$PREFIX/scripts/$(basename "$f")"
                if [ -f "$INCOMING" ] && ! cmp -s "$f" "$INCOMING"; then
                    cp "$INCOMING" "$f"
                    chmod +x "$f"
                    git add "$f"
                fi
            done

            if ! git commit --no-edit; then
                echo "Error: could not finish the subtree merge commit even after resyncing scripts/*.sh." >&2
                echo "  Resolve manually (git status), then run 'git commit --no-edit' to finish the same merge." >&2
                exit 1
            fi
        else
            # Fallback: projects created from a GitHub template repo don't
            # carry git history, so git subtree pull has no shared history to
            # diff against (see README's "projects created from a template
            # repository" note). Re-sync by replacing $PREFIX wholesale.
            echo "git subtree pull failed (likely no shared history — a template-repo checkout). Falling back to a full re-sync..."
            git reset --hard HEAD
            git clean -fd "$PREFIX/"
            SPLIT=$(git rev-parse "${REMOTE_NAME}/${BRANCH}")
            rm -rf "$PREFIX"
            mkdir -p "$PREFIX"
            git archive "${REMOTE_NAME}/${BRANCH}" | tar -x -C "$PREFIX/"
            git add "$PREFIX/"
            if ! git diff --cached --quiet; then
                MSG=$(printf 'Squashed '\''%s/'\'' content from commit %s\n\ngit-subtree-dir: %s\ngit-subtree-split: %s' \
                    "$PREFIX" "$SPLIT" "$PREFIX" "$SPLIT")
                # This commit never goes through `git subtree`'s own merge
                # machinery (there's no shared history to merge against), so
                # a plain `git commit` here is unconditionally blocked by
                # check-charter-subtree-edit.sh whenever it's installed and
                # active — that hook's MERGE_HEAD exemption only ever fires
                # for an actual merge commit, regardless of how current the
                # local hook copy is. Reproduce the same MERGE_HEAD +
                # synthetic squash-commit shape a real subtree merge leaves
                # behind (verified to stay compatible with a later real
                # `git subtree pull`), so this finishes as a real merge
                # commit and the hook's existing exemption applies.
                SQUASH_COMMIT=$(git commit-tree "$(git write-tree)" -p "$SPLIT" -m "$MSG")
                echo "$SQUASH_COMMIT" > "$(git rev-parse --git-path MERGE_HEAD)"
                printf '%s\n' "$MSG" > "$(git rev-parse --git-path MERGE_MSG)"
                if ! git commit --no-edit; then
                    echo "Error: could not finish the re-sync commit under $PREFIX." >&2
                    echo "  Resolve manually (git status), then run 'git commit --no-edit' to finish the same merge." >&2
                    exit 1
                fi
            fi
        fi
    fi

    if [ "$STASHED" = "1" ]; then
        git stash pop
    fi

    # lite には UPDATE_CHECKLIST.md がない（full 専用ファイルのため
    # scripts/charter-manifest.txt で除外）ので、branch ごとにプロンプトを変える。
    if [ "$BRANCH" = "full" ]; then
        NEXT_PROMPT="${PREFIX}/UPDATE_CHECKLIST.md を実行して"
        NEXT_PROMPT_EN="Run ${PREFIX}/UPDATE_CHECKLIST.md"
    else
        NEXT_PROMPT="${PREFIX}/CHARTER_INDEX.md を読み、変更点をこのプロジェクトに反映して"
        NEXT_PROMPT_EN="Read ${PREFIX}/CHARTER_INDEX.md and apply the changes to this project"
    fi

    cat <<EOF

dev-charter updated at $PREFIX

Next — paste this prompt into your AI tool (Claude Code, Copilot, Gemini, etc.):

  $NEXT_PROMPT
  (English: $NEXT_PROMPT_EN)

EOF

    offer_claude_launch "$NEXT_PROMPT"
    exit 0
fi

# 2.5. Nothing is installed yet. If this was invoked in update-only mode
# (e.g. from a Makefile target), don't silently fall through and install
# the default `full` — that would surprise someone who wanted lite. Ask
# interactively, or print guidance and stop if there's no terminal to ask.
if [ "${CHARTER_UPDATE_ONLY:-0}" = "1" ]; then
    echo "dev-charter is not installed at $PREFIX yet — nothing to update."
    if [ -t 0 ]; then
        printf "Install full or lite now? [F/l] "
        read -r answer
        case "${answer:-F}" in
            [Ll]*) BRANCH="lite" ;;
            *) BRANCH="full" ;;
        esac
        echo "Installing $BRANCH..."
    else
        cat <<EOF >&2
Run one of these to install it (this only updates an existing install):
  curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh | bash
  curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh | CHARTER_BRANCH=lite bash
EOF
        exit 1
    fi
fi

# 3. Add remote if not present
if ! git remote get-url "$REMOTE_NAME" > /dev/null 2>&1; then
    echo "Adding remote '$REMOTE_NAME'..."
    git remote add "$REMOTE_NAME" "$REMOTE_URL"
fi

# 4. Fetch
echo "Fetching $REMOTE_NAME..."
git fetch "$REMOTE_NAME"

# 5. Install via git subtree
echo "Installing dev-charter to $PREFIX..."
git subtree add --prefix="$PREFIX" "$REMOTE_NAME" "$BRANCH" --squash

# 6. Success message + prompt examples
# lite には INSTALL_CHECKLIST.md がない（full 専用ファイルのため
# scripts/charter-manifest.txt で除外）ので、branch ごとにプロンプトを変える。
if [ "$BRANCH" = "full" ]; then
    NEXT_PROMPT="${PREFIX}/INSTALL_CHECKLIST.md を実行して"
    NEXT_PROMPT_EN="Run ${PREFIX}/INSTALL_CHECKLIST.md"
else
    NEXT_PROMPT="${PREFIX}/CHARTER_INDEX.md を読み、このプロジェクトに合わせて AI_CONTEXT.md 等を構成して"
    NEXT_PROMPT_EN="Read ${PREFIX}/CHARTER_INDEX.md and set up AI_CONTEXT.md etc. for this project"
fi

cat <<EOF

dev-charter installed at $PREFIX

Next — paste this prompt into your AI tool (Claude Code, Copilot, Gemini, etc.):

  $NEXT_PROMPT
  (English: $NEXT_PROMPT_EN)

EOF

# 7. Offer to launch Claude Code if available
offer_claude_launch "$NEXT_PROMPT"
