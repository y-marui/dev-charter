# Dev Charter (lite)

> **このファイルは正本（日本語版）です。**
> 英語版（参照）は [README.md](README.md) を参照してください。

[dev-charter](https://github.com/y-marui/dev-charter) の **lite** 版。
プロジェクト種別を問わず普遍的に価値がある部分（AI コンテキストの整備、
GitHub Issues/Projects でのタスク管理、シークレット管理等）だけを収録して
いる。Python 開発環境・UI デザイン・収益化方針などソフトウェアプロジェクト
固有の内容は含まれない。収録内容は [CHARTER_INDEX.md](CHARTER_INDEX.md) を
参照。それらが必要な場合は `full` ブランチを検討すること。

## Install (git subtree)

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git fetch dev-charter
git subtree add --prefix=docs/dev-charter dev-charter lite --squash
```

インストール後、以下のプロンプトを AI ツールに貼り付けてください：

```
docs/dev-charter/CHARTER_INDEX.md を読み、このプロジェクトに合わせて AI_CONTEXT.md 等を構成して
```

Quick Install のワンライナーでも同じことができる：

```bash
CHARTER_BRANCH=lite bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

## Update

Quick Install のワンライナーを再実行するだけでも更新できる。既存の導入と
そのブランチ（ここでは lite）を検知して `git subtree pull` を自動実行する
（未コミットの変更があれば自動で stash/復元し、テンプレートリポジトリの
場合は完全な再同期にフォールバックする）：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

手動で更新する場合：`dev-charter` リモートが未設定の場合（プロジェクトを clone した直後など）は先に追加する：

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git subtree pull --prefix=docs/dev-charter dev-charter lite --squash
```

> **Note（テンプレートリポジトリから作成したプロジェクト）:**
> GitHub テンプレートはファイルのみコピーし git 履歴を引き継がないため、`git subtree pull` は失敗します。
> `check-charter.yml` ワークフローがこのケースを自動検出して対処します。
> 手動で更新する場合は `git subtree pull` の代わりに以下を実行してください：
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

更新後は `git diff HEAD~1 HEAD --name-only -- docs/dev-charter/` で変更ファイル
を確認し、AI ツールにプロジェクトへの反映を依頼すること（lite には独立した
`UPDATE_CHECKLIST.md` が無い）。

## More

Makefile Helper・Version Check (CI)・Badge の設定については
[dev-charter 本体の README-jp.md](https://github.com/y-marui/dev-charter/blob/main/README-jp.md) を参照。

---

*この文書には英語版 [README.md](README.md) があります。編集時は同一コミットで更新してください。*
