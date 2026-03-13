# Dev Charter (開発憲章)

AI支援ソフトウェアプロジェクトのための共有開発憲章。

このリポジトリは、プロジェクト横断的に使用される共通の哲学、アーキテクチャ原則、
および開発ルールを定義します。

## インストール (git subtree)

```
git remote add dev-charter https://github.com/USERNAME/dev-charter
git fetch dev-charter
git subtree add --prefix=docs/dev-charter dev-charter main --squash
```

## 更新

```
git subtree pull --prefix=docs/dev-charter dev-charter main --squash
```

## Makefile ヘルパー

```
update-charter:
	git subtree pull --prefix=docs/dev-charter dev-charter main --squash
```