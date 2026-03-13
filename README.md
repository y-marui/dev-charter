# Dev Charter

Shared development charter for AI-assisted software projects.

This repository defines common philosophy, architecture principles,
and development rules used across projects.

## Install (git subtree)

```
git remote add dev-charter https://github.com/USERNAME/dev-charter
git fetch dev-charter
git subtree add --prefix=docs/dev-charter dev-charter main --squash
```

## Update

```
git subtree pull --prefix=docs/dev-charter dev-charter main --squash
```

## Makefile helper

```
update-charter:
	git subtree pull --prefix=docs/dev-charter dev-charter main --squash
```
