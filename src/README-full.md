# Dev Charter (full)

> **This is the reference (English) version.**
> For the canonical (Japanese) version, see [README-jp.md](README-jp.md).

The **full** variant of [dev-charter](https://github.com/y-marui/dev-charter)
(the whole charter). Includes software-project-specific content — Python dev
environment, UI design, monetization policy, and so on. See
[CHARTER_INDEX.md](CHARTER_INDEX.md) for what's included. If you need a
lighter variant for documentation-only repositories, consider the `lite`
branch instead.

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

The Quick Install one-liner does the same thing:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

## Update

Re-running the Quick Install one-liner also works for updates — it detects
the existing install and its branch (here, full), then runs `git subtree
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

## More

For the Makefile helper, Version Check (CI), and badge setup, see
[dev-charter's own README.md](https://github.com/y-marui/dev-charter/blob/main/README.md).

---

*This document has a Japanese canonical version [README-jp.md](README-jp.md). Update both in the same commit when editing.*
