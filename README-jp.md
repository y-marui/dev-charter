# Dev Charter (開発憲章)

> **このファイルは正本（日本語版）です。**
> 英語版（参照）は [README.md](README.md) を参照してください。

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](LICENSE)
[![check-charter CI](https://github.com/y-marui/dev-charter/actions/workflows/check-charter.yml/badge.svg)](https://github.com/y-marui/dev-charter/actions/workflows/check-charter.yml)

AI支援ソフトウェアプロジェクトのための共有開発憲章。

このリポジトリは、プロジェクト横断的に使用される共通の哲学、アーキテクチャ原則、
および開発ルールを定義します。

## Documents

憲章ドキュメントの一覧とトピック別の参照先は、正本である [src/CHARTER_INDEX.md](src/CHARTER_INDEX.md) を参照してください。

> **Note:** このリポジトリ自身のルート（`AI_CONTEXT.md`・`CLAUDE.md`・
> `GEMINI.md`・`AGENTS.md`・この README）は、*dev-charter 自体を編集する* AI
> ツール向けです。採用先プロジェクトへ配布される憲章コンテンツは
> [`src/`](src/) 配下にあり、`full`/`lite` ブランチとして公開されます。

## Full and Lite Version

dev-charter は 2 種類のブランチとして配布されます：

- **full**（既定）：Python 開発環境・UI デザイン・収益化方針などソフトウェア
  プロジェクト固有の内容を含む、憲章の全体
- **lite**：ドキュメントのみのリポジトリ（設定ファイル集、ノートアーカイブ等）
  向けに、プロジェクト種別を問わず普遍的に価値がある部分（AI コンテキストの
  整備、GitHub Issues/Projects でのタスク管理、シークレット管理等）だけに
  絞ったもの

収録ファイルの分類は [scripts/charter-manifest.txt](scripts/charter-manifest.txt) を参照。
`git subtree` を使った手動導入・更新手順など各バリアントの詳細は
[src/README-full-jp.md](src/README-full-jp.md)（full）・
[src/README-lite-jp.md](src/README-lite-jp.md)（lite）を参照してください
（採用先にはそれぞれ `docs/dev-charter/README-jp.md` として同梱されます）。

## How to Use

1. `git subtree` で `docs/dev-charter/` に取り込む
2. AI に dev-charter を読ませ、プロジェクトルートに `AI_CONTEXT.md` と AI ツール設定ファイルを生成させる
3. 憲章が更新されたら `git subtree pull` 後、AI にコンテキストファイルを追従させる

構成仕様は [src/AI_TOOL_SETUP.md](src/AI_TOOL_SETUP.md) を参照。

## Quick Install

プロジェクトのルートで実行してください：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

Windows PowerShell の場合：

```powershell
irm https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.ps1 | iex
```

lite 版を導入する場合は `CHARTER_BRANCH=lite`（PowerShell では
`$env:CHARTER_BRANCH = 'lite'`）を付けてください：

```bash
CHARTER_BRANCH=lite bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

スクリプトが git subtree のセットアップを自動化し、Claude Code が利用可能であれば
初回セットアップ（INSTALL_CHECKLIST）の起動まで案内します。**同じワンライナーを
再実行すると更新にもなります**（導入済みのブランチを自動判定するため、
`git subtree pull` を手で打つ必要はありません）。

> **Note:** インストール先を変更する場合は環境変数で指定できます：
> `CHARTER_PREFIX=path/to/charter bash <(curl -fsSL .../install.sh)`

インストール後、以下のプロンプトを AI ツールに貼り付けてください（full の場合）：

```
docs/dev-charter/INSTALL_CHECKLIST.md を実行して
```

lite の場合はスクリプトが別のプロンプトを表示します。`git subtree` を使った
手動導入・更新手順やテンプレートリポジトリでの対応は
[src/README-full-jp.md](src/README-full-jp.md)（full）・
[src/README-lite-jp.md](src/README-lite-jp.md)（lite）を参照してください。

## Makefile Helper

更新は Quick Install のワンライナー（`scripts/install.sh`）が stash/復元・
ブランチ自動判定まで面倒を見るため、Makefile からはこれを呼ぶだけで十分です：

```
.PHONY: update-charter
update-charter:
	bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

## Version Check (CI)

`.github/workflows/dev-charter-check.yml` をプロジェクトに追加すると、
PR作成や main への push をきっかけに最新バージョンを確認し、古い場合は update PR を作成します
（直近7日以内に成功したチェックがあればスキップするため、活発な repo でも毎回チェックが走ることはありません）。

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

> **Note:** dependabot が作成した PR や draft PR では `check` 自体がスキップされます
> （後述）。`gate` はその場合も `skipped` を正常として扱い、必ず `Dev Charter`（ワークフロー
> 自身の `name:` と同じ値）を報告します。Branch Protection（Ruleset）に必須ステータス
> チェックとして登録するのは `Check / check` ではなく `Dev Charter` です（[CI_POLICY.md
> の Ruleset 節](topics/CI_POLICY.md#branch-protection-ruleset)参照）。
> `check` job だけを直接必須チェックに登録すると、skip 時に `Check / check` という
> コンテキスト自体が一切報告されず、PR が `Expected — Waiting for status to be reported`
> のまま永久にブロックされます。

> **Note:** dependabot が作成した PR ではスキップされます（依存関係更新だけが動いている間はチェック不要という判断）。
> repo が完全に静止している間はチェックが走らないため、活動に関わらず定期的に確認したい場合は
> 上記に加えて低頻度の `schedule`（例：月1回）を併用してください。

> **Note:** Draft PR ではスキップされます（draft はそもそもマージできないため、チェックが
> 未報告のままでもリスクがない）。`on.pull_request.types` の `ready_for_review` により、
> draft を解除した際は改めて実行されます。

> **Note:** Branch Protection で direct push が禁止されている場合は、
> GitHub Actions bot の bypass rule を追加してください
> （Settings > Rules > Rulesets > Bypass list > GitHub Actions）。

## Badge for Adopting Projects

プロジェクトの README にこのバッジを追加すると、dev-charter の更新状態を可視化できます。

### Workflow Status Badge

dev-charter が最新かどうかを表示します。

```markdown
[![Charter Check](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml/badge.svg)](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml)
```

`{owner}` と `{repo}` を自分のリポジトリのオーナー名・リポジトリ名に置き換えてください。

| 状態 | Status Badge |
|---|---|
| 未導入 / CI 未設定 | 赤（VERSION not found） |
| 導入済み・最新 | 緑 |
| 導入済み・更新必要 | 赤 |

---

*この文書には英語版 [README.md](README.md) があります。編集時は同一コミットで更新してください。*
