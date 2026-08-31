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

If you want `make update-charter` as part of your workflow, a thin target
that just calls the Quick Install one-liner is enough (same for both full
and lite). See the exact target definition in
[src/README-full.md](src/README-full.md) (full) /
[src/README-lite.md](src/README-lite.md) (lite).

## Version Check (CI)

Add `.github/workflows/dev-charter-check.yml` to your project to check for
updates when a PR is opened or a commit is pushed to main, and open an
update PR if outdated. **The workflow differs slightly between full and
lite** (lite needs `branch: lite` set explicitly). For the exact template
and setup notes (Dependabot/draft-PR skip behavior, Branch Protection
setup, etc.), see
[src/README-full.md](src/README-full.md) (full) /
[src/README-lite.md](src/README-lite.md) (lite).

## Badge for Adopting Projects

You can add a badge to your project README showing the Version Check (CI)
status (same for both full and lite). See the badge Markdown and status
table in
[src/README-full.md](src/README-full.md) (full) /
[src/README-lite.md](src/README-lite.md) (lite).

---

*This document has a Japanese canonical version [README-jp.md](README-jp.md). Update both in the same commit when editing.*
