# Dev Charter (lite)

> **このファイルは正本（日本語版）です。**
> 英語版（参照）は [README.md](README.md) を参照してください。

[dev-charter](https://github.com/y-marui/dev-charter) の **lite** 版。
プロジェクト種別を問わず普遍的に価値がある部分（AI コンテキストの整備、
GitHub Issues/Projects でのタスク管理、シークレット管理等）だけを収録して
いる。Python 開発環境・UI デザイン・収益化方針などソフトウェアプロジェクト
固有の内容は含まれない（それらが必要な場合は `full` ブランチを導入すること）。
収録内容は [CHARTER_INDEX.md](CHARTER_INDEX.md) を参照。

## Update

`dev-charter` リモートが未設定の場合（プロジェクトを clone した直後など）は先に追加する：

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
`UPDATE_CHECKLIST.md` が無い。full 版のチェックリストを参考にしたい場合は
[dev-charter 本体の README-jp.md](https://github.com/y-marui/dev-charter/blob/main/README-jp.md#update)
を参照）。

## Makefile Helper

`git subtree pull` は作業ツリーに未コミットの変更があると失敗するため、
実行前に自動で `git stash` し、完了後に `git stash pop` で戻す。

導入時に `full` と `lite` のどちらを選んだかをこのターゲットが覚えている必要
はない。このファイルの `# Charter Index (<branch>)` マーカーから毎回導入済み
ブランチを自動判定するため、取り違えて更新してしまう事故（full 導入なのに
lite で上書き、またはその逆）を防げる。

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

`.github/workflows/dev-charter-check.yml` をプロジェクトに追加すると、
PR作成や main への push をきっかけに最新バージョンを確認し、古い場合は
update PR を作成する。この variant を追跡するために `branch: lite` を指定する：

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

Dependabot/draft PR のスキップ挙動や Branch Protection の設定については
[dev-charter 本体の README-jp.md](https://github.com/y-marui/dev-charter/blob/main/README-jp.md#version-check-ci)
を参照。

## Badge for Adopting Projects

プロジェクトの README にこのバッジを追加すると、dev-charter の更新状態を可視化できる。

```markdown
[![Charter Check](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml/badge.svg)](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml)
```

`{owner}` と `{repo}` を自分のリポジトリのオーナー名・リポジトリ名に置き換えること。

---

*この文書には英語版 [README.md](README.md) があります。編集時は同一コミットで更新してください。*
