# Dev Charter

> **This is the reference (English) version.**
> For the canonical (Japanese) version, see [README-jp.md](README-jp.md).

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](LICENSE)
[![check-charter CI](https://github.com/y-marui/dev-charter/actions/workflows/check-charter.yml/badge.svg)](https://github.com/y-marui/dev-charter/actions/workflows/check-charter.yml)

Shared development charter for AI-assisted software projects.

This repository defines common philosophy, architecture principles,
and development rules used across projects.

## Documents

See the canonical [src/CHARTER_INDEX.md](src/CHARTER_INDEX.md) for the complete document list and topic-to-file lookup table.

> **Note:** This repository's own root (`AI_CONTEXT.md`, `CLAUDE.md`, `GEMINI.md`,
> `AGENTS.md`, this README) is for AI tools editing *dev-charter itself*. The
> charter content distributed to adopting projects lives under
> [`src/`](src/) and is published as the `full` and `lite` branches — see
> below.

## How to Use

1. Pull dev-charter into `docs/dev-charter/` via `git subtree`
2. Have the AI read the charter and generate `AI_CONTEXT.md` and agent config files at the project root
3. After charter updates, run `git subtree pull` and have the AI sync the context files

See [src/AI_TOOL_SETUP.md](src/AI_TOOL_SETUP.md) for the structure spec.

## Quick Install

Run from your project root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

On Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.ps1 | iex
```

The script automates the git subtree setup and, if Claude Code is available,
guides you through the initial setup (INSTALL_CHECKLIST).

> **Note:** To customize the install path or branch, use environment variables:
> `CHARTER_PREFIX=path/to/charter bash <(curl -fsSL .../install.sh)`

## Install (git subtree)

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git fetch dev-charter
git subtree add --prefix=docs/dev-charter dev-charter full --squash
```

After installing, paste the following prompt into your AI tool:

```
Run docs/dev-charter/INSTALL_CHECKLIST.md
```

## Update

Re-running the Quick Install one-liner also works for updates — it detects
the existing install and its branch (full/lite), then runs `git subtree
pull` for you (stashing/restoring uncommitted changes as needed, and falling
back to a full re-sync for template-repo checkouts):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

To update manually instead: if the `dev-charter` remote is not set up (e.g., after cloning the project), add it first:

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git subtree pull --prefix=docs/dev-charter dev-charter full --squash
```

> **Note (if you installed [lite](#lite-version)):** replace `full` above with
> `lite`. Mixing them up swaps full and lite (the [Makefile
> helper](#makefile-helper) auto-detects the installed branch, so it can't
> make this mistake).

> **Note (projects created from a template repository):**
> GitHub templates copy files only — git history is not carried over — so `git subtree pull` will fail.
> The `check-charter.yml` workflow detects this automatically and handles it.
> For manual updates, use the following instead of `git subtree pull`:
> ```bash
> git remote add dev-charter https://github.com/y-marui/dev-charter || true
> git fetch dev-charter
> SPLIT=$(git rev-parse dev-charter/full)
> rm -rf docs/dev-charter/
> mkdir -p docs/dev-charter/
> git archive dev-charter/full | tar -x -C docs/dev-charter/
> git add docs/dev-charter/
> git commit -m "Squashed 'docs/dev-charter/' content from commit ${SPLIT}
>
> git-subtree-dir: docs/dev-charter
> git-subtree-split: ${SPLIT}"
> ```

After updating, paste the following prompt into your AI tool:

```
Run docs/dev-charter/UPDATE_CHECKLIST.md
```

## Lite Version

The `full` branch (built from [`src/`](src/)) includes a lot of
software-project-specific content — Python dev environment, UI design,
monetization policy, and so on. For documentation-only repositories (dotfiles
collections, note archives, etc.) where installing the full charter is
overkill, the `lite` branch carries only the parts that are universally
valuable regardless of project type (AI context maintenance, task management
via GitHub Issues/Projects, secrets management, etc.). See
[scripts/charter-manifest.txt](scripts/charter-manifest.txt) for how files
are classified.

Quick Install (set `CHARTER_BRANCH=lite`):

```bash
CHARTER_BRANCH=lite bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

Installing directly via git subtree:

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git fetch dev-charter
git subtree add --prefix=docs/dev-charter dev-charter lite --squash
```

For Version Check (CI), pass `branch: lite`:

```yaml
    uses: y-marui/dev-charter/.github/workflows/check-charter.yml@main
    with:
      branch: lite
```

lite's `VERSION` is tracked independently from full's, and only updates when
the included files' content actually changes (so unrelated full-side changes
don't trigger update PRs for lite adopters).

A lite-only checkout doesn't include this README, `INSTALL_CHECKLIST.md`, or
`UPDATE_CHECKLIST.md`. Instead, `scripts/publish-branch.sh` renames
[`src/README-lite.md`](src/README-lite.md) to `README.md` when it builds the
`lite` branch, so lite adopters get self-contained update instructions
without needing to install full.

## Makefile helper

`git subtree pull` fails if the working tree has uncommitted changes, so this
target automatically stashes before running and pops afterward.

This target doesn't need to remember whether you installed `full` or `lite`
(or another distribution branch added later). It auto-detects the installed
branch every time from the existing `docs/dev-charter/CHARTER_INDEX.md`'s
`# Charter Index (<branch>)` marker (generated by `scripts/publish-branch.sh`;
absence of a marker means `full`), which prevents the accident of updating a
full install with lite or vice versa.

```
.PHONY: update-charter
update-charter:
	git remote | grep -q '^dev-charter$$' || \
	  git remote add dev-charter https://github.com/y-marui/dev-charter
	git fetch dev-charter
	@BRANCH=full; \
	MARKER=$$(head -1 docs/dev-charter/CHARTER_INDEX.md 2>/dev/null | grep -oE '\([a-z0-9_-]+\)$$' | tr -d '()'); \
	[ -n "$$MARKER" ] && BRANCH=$$MARKER; \
	echo "dev-charter branch: $$BRANCH"; \
	STASHED=0; \
	if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$$(git ls-files --others --exclude-standard)" ]; then \
		git stash push -u -m "update-charter"; \
		STASHED=1; \
	fi; \
	git subtree pull --prefix=docs/dev-charter dev-charter $$BRANCH --squash; \
	if [ "$$STASHED" = "1" ]; then git stash pop; fi
```

## Version Check (CI)

Add `.github/workflows/dev-charter-check.yml` to your project to check for updates
when a PR is opened or a commit is pushed to main, and open an update PR if outdated
(the check is skipped if one already succeeded within the last 7 days, so busy repos
don't re-check on every single event).

```yaml
name: Dev Charter

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  check:
    name: Check
    if: github.actor != 'dependabot[bot]' && (github.event_name != 'pull_request' || github.event.pull_request.draft == false)
    uses: y-marui/dev-charter/.github/workflows/check-charter.yml@main
    permissions:
      contents: write
      pull-requests: write
      actions: read

  gate:
    name: Dev Charter
    needs: [check]
    if: always()
    runs-on: ubuntu-latest
    steps:
      - name: Verify dev-charter check did not fail
        run: |
          result="${{ needs.check.result }}"
          if [ "$result" = "failure" ] || [ "$result" = "cancelled" ]; then
            echo "::error::dev-charter check did not succeed (got: $result)"
            exit 1
          fi
          echo "check result: $result (skipped is fine — draft or dependabot)"
```

> **Note:** `check` is skipped for Dependabot PRs and draft PRs (see below). `gate`
> treats a `skipped` result as fine in both cases and always reports a `Dev Charter`
> status (matching this workflow's own `name:`). Register `Dev Charter` — not `Check /
> check` — as the required status check in Branch Protection (Ruleset); see
> [CI_POLICY.md's Ruleset section](topics/CI_POLICY.md#branch-protection-ruleset).
> Registering the `check` job itself is unsafe: when it's skipped, the `Check / check`
> context is never reported at all, so the PR sits at "Expected — Waiting for status to
> be reported" forever.

> **Note:** Dependabot PRs are skipped — dependency-only activity doesn't warrant a
> charter check. If your repository goes fully quiet, no check will run. If you want a
> guaranteed periodic check regardless of activity, add a low-frequency `schedule`
> (e.g. monthly) alongside this.

> **Note:** Draft PRs are skipped (a draft can't be merged anyway, so there's no risk
> in leaving the check unreported). `ready_for_review` in `on.pull_request.types` makes
> sure taking a PR out of draft re-triggers a real run.

> **Note:** If your repository has Branch Protection rules that prevent direct pushes,
> add a bypass rule for the GitHub Actions bot
> (Settings > Rules > Rulesets > Bypass list > GitHub Actions).

## Badge for Adopting Projects

Place this badge in your project README to show dev-charter update health.

### Workflow Status Badge

Shows whether dev-charter is up to date.

```markdown
[![Charter Check](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml/badge.svg)](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml)
```

Replace `{owner}` and `{repo}` with your GitHub organization and repository name.

| State | Status Badge |
|---|---|
| Not installed / CI not set up | red (VERSION not found) |
| Installed, up to date | green |
| Installed, outdated | red |

---

*This document has a Japanese canonical version [README-jp.md](README-jp.md). Update both in the same commit when editing.*
