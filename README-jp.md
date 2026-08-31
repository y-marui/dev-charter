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

`make update-charter` のような形で更新を Makefile に組み込みたい場合は、
Quick Install のワンライナーを呼ぶだけの薄いターゲットで足ります（full/lite
共通）。具体的なターゲット定義は
[src/README-full-jp.md](src/README-full-jp.md)（full）・
[src/README-lite-jp.md](src/README-lite-jp.md)（lite）を参照してください。

## Version Check (CI)

`.github/workflows/dev-charter-check.yml` をプロジェクトに追加すると、
PR作成や main への push をきっかけに最新バージョンを確認し、古い場合は update PR を
作成できます。**full と lite でワークフローの中身が少し違います**（lite は
`branch: lite` を明示的に指定する必要があります）。正確なテンプレートと
Dependabot/draft PR のスキップ挙動・Branch Protection 設定などの詳細は
[src/README-full-jp.md](src/README-full-jp.md)（full）・
[src/README-lite-jp.md](src/README-lite-jp.md)（lite）を参照してください。

## Badge for Adopting Projects

プロジェクトの README に、Version Check (CI) の状態を示すバッジを追加できます
（full/lite 共通）。バッジの Markdown と状態一覧は
[src/README-full-jp.md](src/README-full-jp.md)（full）・
[src/README-lite-jp.md](src/README-lite-jp.md)（lite）を参照してください。

---

*この文書には英語版 [README.md](README.md) があります。編集時は同一コミットで更新してください。*
