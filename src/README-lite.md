# Dev Charter (lite)

> **This is the reference (English) version.**
> For the canonical (Japanese) version, see [README-jp.md](README-jp.md).

The **lite** variant of [dev-charter](https://github.com/y-marui/dev-charter):
only the parts that are universally valuable regardless of project type (AI
context maintenance, task management via GitHub Issues/Projects, secrets
management, etc.). Software-project-specific content (Python dev environment,
UI design, monetization policy, and so on) is not included. See
[CHARTER_INDEX.md](CHARTER_INDEX.md) for what's included. If you need that
content, consider the `full` branch instead.

## Install (git subtree)

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git fetch dev-charter
git subtree add --prefix=docs/dev-charter dev-charter lite --squash
```

After installing, paste the following prompt into your AI tool:

```
Read docs/dev-charter/CHARTER_INDEX.md and set up AI_CONTEXT.md etc. for this project
```

The Quick Install one-liner does the same thing:

```bash
CHARTER_BRANCH=lite bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

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

After updating, run `git diff HEAD~1 HEAD --name-only -- docs/dev-charter/`
to see what changed and have your AI tool apply it to the project (lite
doesn't have its own `UPDATE_CHECKLIST.md`).

## More

For the Makefile helper, Version Check (CI), and badge setup, see
[dev-charter's own README.md](https://github.com/y-marui/dev-charter/blob/main/README.md).

---

*This document has a Japanese canonical version [README-jp.md](README-jp.md). Update both in the same commit when editing.*
