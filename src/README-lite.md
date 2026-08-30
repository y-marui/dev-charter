# Dev Charter (lite)

> **This is the reference (English) version.**
> For the canonical (Japanese) version, see [README-jp.md](README-jp.md).

This is the **lite** variant of [dev-charter](https://github.com/y-marui/dev-charter):
only the parts that are universally valuable regardless of project type (AI
context maintenance, task management via GitHub Issues/Projects, secrets
management, etc.). Software-project-specific content (Python dev environment,
UI design, monetization policy, and so on) is not included — install the
`full` branch instead if you need those. See
[CHARTER_INDEX.md](CHARTER_INDEX.md) for what's included.

## Update

Re-running the Quick Install one-liner also works for updates — it detects
the existing install and its branch (here, lite), then runs `git subtree
pull` for you (stashing/restoring uncommitted changes as needed, and falling
back to a full re-sync for template-repo checkouts):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

To update manually instead: if the `dev-charter` remote is not set up (e.g., after cloning the project), add it first:

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git subtree pull --prefix=docs/dev-charter dev-charter lite --squash
```

> **Note (projects created from a template repository):**
> GitHub templates copy files only — git history is not carried over — so `git subtree pull` will fail.
> The `check-charter.yml` workflow detects this automatically and handles it.
> For manual updates, use the following instead of `git subtree pull`:
> ```bash
> git remote add dev-charter https://github.com/y-marui/dev-charter || true
> git fetch dev-charter
> SPLIT=$(git rev-parse dev-charter/lite)
> rm -rf docs/dev-charter/
> mkdir -p docs/dev-charter/
> git archive dev-charter/lite | tar -x -C docs/dev-charter/
> git add docs/dev-charter/
> git commit -m "Squashed 'docs/dev-charter/' content from commit ${SPLIT}
>
> git-subtree-dir: docs/dev-charter
> git-subtree-split: ${SPLIT}"
> ```

After updating, read the changed files listed by
`git diff HEAD~1 HEAD --name-only -- docs/dev-charter/` and have your AI tool
apply the changes to this project (there is no separate `UPDATE_CHECKLIST.md`
in lite — see [dev-charter's own README-jp.md](https://github.com/y-marui/dev-charter/blob/main/README-jp.md#update)
if you want the full-version checklist for reference).

## Makefile helper

`git subtree pull` fails if the working tree has uncommitted changes, so this
target automatically stashes before running and pops afterward.

This target doesn't need to remember whether you installed `full` or `lite`.
It auto-detects the installed branch every time from this file's
`# Charter Index (<branch>)` marker, which prevents the accident of updating
a full install with lite or vice versa.

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

Add `.github/workflows/dev-charter-check.yml` to your project to check for
updates when a PR is opened or a commit is pushed to main, and open an update
PR if outdated. Pass `branch: lite` so the check tracks this variant:

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
    with:
      branch: lite
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

See [dev-charter's own README-jp.md](https://github.com/y-marui/dev-charter/blob/main/README-jp.md#version-check-ci)
for the notes on Dependabot/draft-PR skip behavior and Branch Protection setup.

## Badge for Adopting Projects

Place this badge in your project README to show dev-charter update health.

```markdown
[![Charter Check](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml/badge.svg)](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml)
```

Replace `{owner}` and `{repo}` with your GitHub organization and repository name.

---

*This document has a Japanese canonical version [README-jp.md](README-jp.md). Update both in the same commit when editing.*
