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
> [`src/`](src/) and is published as the `full` and `lite` branches.

## Full and Lite Version

dev-charter is distributed as two branches:

- **full** (default): the whole charter, including software-project-specific
  content — Python dev environment, UI design, monetization policy, and so on
- **lite**: for documentation-only repositories (dotfiles collections, note
  archives, etc.), only the parts that are universally valuable regardless of
  project type (AI context maintenance, task management via GitHub
  Issues/Projects, secrets management, etc.)

See [scripts/charter-manifest.txt](scripts/charter-manifest.txt) for how
files are classified. For manual `git subtree` install/update steps and
other per-variant details, see
[src/README-full.md](src/README-full.md) (full) /
[src/README-lite.md](src/README-lite.md) (lite) — these are also what get
bundled into an adopting project as `docs/dev-charter/README.md`.

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

To install lite instead, add `CHARTER_BRANCH=lite` (PowerShell:
`$env:CHARTER_BRANCH = 'lite'`):

```bash
CHARTER_BRANCH=lite bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

The script automates the git subtree setup and, if Claude Code is available,
guides you through the initial setup (INSTALL_CHECKLIST). **Re-running the
same one-liner also updates** — it detects the existing install and its
branch, so you never need to type `git subtree pull` by hand.

> **Note:** To customize the install path, use an environment variable:
> `CHARTER_PREFIX=path/to/charter bash <(curl -fsSL .../install.sh)`

After installing, paste the following prompt into your AI tool (for full):

```
Run docs/dev-charter/INSTALL_CHECKLIST.md
```

For lite, the script prints a different prompt. For manual `git subtree`
install/update steps and the template-repository fallback, see
[src/README-full.md](src/README-full.md) (full) /
[src/README-lite.md](src/README-lite.md) (lite).

## Makefile helper

Updating is handled by the Quick Install one-liner (`scripts/install.sh`)
itself — it stashes/restores changes and auto-detects the installed branch —
so a Makefile target just needs to call it. Adding `CHARTER_UPDATE_ONLY=1`
means that if this target is ever run before anything is installed, it
won't silently install `full` — it asks which branch you want instead
(or errors out with guidance in a non-interactive environment):

```
.PHONY: update-charter
update-charter:
	CHARTER_UPDATE_ONLY=1 bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
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
