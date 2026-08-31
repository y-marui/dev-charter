## Reference Order

AI はタスク開始時に以下の順で参照する：

1. `README-jp.md`（このリポジトリの概要・導入・更新方法）
2. `src/CHARTER_INDEX.md`（タスクに関係する憲章ファイルの特定）
3. `src/CHARTER_INDEX.md` で特定したファイル（原則 1〜2 件）

## Project Overview

dev-charter の本体。他プロジェクトが `git subtree` で取り込む共有開発憲章。
ドキュメントのみのリポジトリ（ソースコードなし）。

このファイルは **dev-charter リポジトリ自体を作業する AI 向け**のコンテキスト。
採用先プロジェクトへの導入手順は `README-jp.md` を参照すること。

`src/` 配下が採用先へ配布される憲章コンテンツの実体で、`full`/`lite` ブランチは
`main` への push をきっかけに `scripts/publish-branch.sh` が `src/` から自動生成
する（各ブランチへの分類ルールは `scripts/charter-manifest.txt` を参照）。
リポジトリルート直下の `AI_CONTEXT.md`・`CLAUDE.md`・`GEMINI.md`・`AGENTS.md`・
`README.md`/`README-jp.md` は dev-charter 自体の編集専用で、配布対象には含まれない。

### Technology Stack

- Markdown：憲章・ガイドライン・チェックリスト
- Bash：インストール・バージョン検証スクリプト（CI・pre-commit の実行基盤）
- PowerShell：上記スクリプトの `.ps1` 版（`src/scripts/*.ps1`）。ローカル Windows 環境向けの並行実装で、CI では未使用（#57 参照）
- GitHub Actions / pre-commit：CI・セキュリティ・文書品質の検証
- アプリケーション用のランタイム・フレームワーク：なし

### Main Directories

| パス | 役割 |
|---|---|
| `/` | dev-charter 自体の編集用 AI コンテキスト・導入手順（配布対象外） |
| `src/` | 採用先へ配布される憲章コンテンツ本体（`full`/`lite` ブランチの生成元） |
| `src/topics/` | 技術・運用トピック別の詳細ガイドライン |
| `src/scripts/` | 採用先に配布される pre-commit フックスクリプト（full のみ） |
| `scripts/` | dev-charter 自身のインストーラ・ブランチ生成・バージョン検証スクリプト |
| `.github/workflows/` | CI・VERSION 更新・ブランチ生成・採用先向け更新ワークフロー |

## Applied Charter Principles

- コンテキストが競合する場合は `AI_CONTEXT_HIERARCHY.md` の優先順位に従う
- 変更範囲を必要最小限にし、YAGNI・既存パターン優先など `PRINCIPLES.md` の設計原則に従う
- シークレット管理と検証は `SECURITY_POLICY.md` に従う

## Document Sync Rule

仕様・ルール・構成に変更が生じたとき、変更と同じ作業内で関連ドキュメントを更新する。
対象は docs/ 内のファイルに限らず、AI_CONTEXT.md・README.md 等のルートファイルも含む。

## Project-Specific Rules

- **正本は日本語**。英語版（README.md）は翻訳。日本語版と英語版は同一コミットで更新する（`LANGUAGE_POLICY.md` 参照）
- **Conventional Commits**（feat/fix/docs/chore）でコミットする
- **`VERSION` は UTC の時間単位（`YYYY-MM-DDThhZ`）で管理する**。同じ日に複数回の意味のある更新が
  あっても、時間が違えば別バージョンとして区別できる（分単位にしないのは、pre-commit フックが
  書き込む時刻と実際の `git commit` 時刻が数秒ズレることがあり、分単位だと境界を跨いで
  マージ時に CI が失敗するリスクがあるため）
  - pre-commit フックが `end-of-file-fixer` と同様に**自動で書き換える**（コミット前に手動で
    更新する必要はない。フックが未ステージの変更を作った場合は `git add VERSION` して
    コミットし直す）
  - **クラウド/エージェント環境**：ローカルの pre-commit フックが動作しない。CI の自動更新ワークフロー（`.github/workflows/update-version.yml`）が `VERSION` を自動的に更新してコミットするため、漏れた場合は CI が補完する。手動で更新する場合は `UPDATE=1 bash scripts/check-version-date.sh`
- **新規ドキュメントを追加するとき**は正本の索引である `src/CHARTER_INDEX.md` を更新し、
  `scripts/charter-manifest.txt` の `[tags]` にも分類を追記する（未分類は `check-charter-manifest`
  フックが pre-commit で検出する）
- **憲章に追加できる原則・ルール**は複数の異なるプロジェクトに適用できるものに限る（1プロジェクト固有のルールは不可）
- **dev-charter 全ドキュメントのセクションヘッダ**：日本語ドキュメントでも英語で記載する
- **ブランチ運用は main + develop の2ブランチモデル**：通常の変更は `develop` 向け
  PR として作成する。ある程度まとまったタイミングで `develop` → `main` の PR を
  作成しマージする（main の更新頻度を抑え、採用先の `check-charter.yml` による
  割り込みを減らすため。`full`/`lite` 等の配布ブランチは `main` への push を
  トリガに `scripts/publish-branch.sh` が再生成し、採用先はそのブランチ自身の
  VERSION を参照するため、develop 運用は採用先には一切見えない）。デフォルト
  ブランチは `main` のまま
- **`develop` という名前は2ブランチ恒久運用の統合ブランチ専用の予約語**。単発の
  作業ブランチには `work/`・`feat/` 等の既存プレフィックスを使う

## CI Workflows

このリポジトリには以下の GitHub Actions ワークフローが存在する：

| ファイル | 目的 |
|---|---|
| `.github/workflows/ci.yml` | PR・main/develop push に対して `pre-commit run --all-files` を実行し、`check-version-date` 等のフックを強制する |
| `.github/workflows/update-version.yml` | 非フォーク PR で `VERSION` が古い場合に自動更新コミットを行う（cloud/agent 対応） |
| `.github/workflows/publish-charter-branches.yml` | `main` への push（`src/**` 変更時）で `full`/`lite` 等の配布ブランチを `scripts/publish-branch.sh` で再生成する |
| `.github/workflows/check-charter.yml` | 採用先プロジェクトから呼び出す再利用可能ワークフロー（dev-charter 本体の CI ではない） |

`ci.yml` の `Build` ジョブが Branch Protection の必須ステータスチェックとして機能する。

## Security Hooks

`core.hooksPath` が設定済みかどうかで手順が異なる：

- **設定済み**（グローバルフックが pre-commit を呼ぶ）：`pre-commit install` 不要。`pre-commit run --all-files` で動作確認
- **未設定**：`pre-commit install` 後に `pre-commit run --all-files` で動作確認

pre-commit は、シークレット・ローカル絶対パス・VERSION 日付・ローカル dev-charter バージョン（sibling `../dev-charter` との比較）・Markdown の H2〜H6 の見出し言語・シェルスクリプトを機械的に検証する。日英文書の意味的一致など判断を要する項目は、AI または人間がレビューする。

確認コマンド：`git config core.hooksPath`

## AI Tool Assignments

- **使用ツール**：Claude Code、Codex、GitHub Copilot、Gemini CLI、ローカル LLM（Ollama）
- **標準担当の正本**：`AI_COLLABORATION_RULES.md` の「AI Tool Responsibilities」と「Rules for Multi-AI Usage」
- **このリポジトリ固有の上書き**：なし

### Migration to Direct MCP Integration

`AI_COLLABORATION_RULES.md` は人間が CLI を個別に叩いてハンドオフする運用を前提に
書かれているが、CLI の対話待ち（stdin blocking）を避けるため、Claude Code から MCP
経由で Codex・GitHub 操作を直結する方向に移行中（本文はまだ更新されていない）。

- Codex: `codex mcp-server`（stdio）で MCP サーバ化できる
- GitHub 操作: 公式ホスト型 GitHub MCP Server（`https://api.githubcopilot.com/mcp/`）を使う。
  OAuth 動的クライアント登録に非対応のため、`gh auth token` の Bearer ヘッダーで認証する
  （`gh auth login` でトークンが失効・再発行されたら MCP サーバーの再登録が必要）
- Gemini CLI・GitHub Copilot CLI はどちらも「MCP サーバとして公開する」モードを持たない
  （`mcp` サブコマンドは外部サーバに繋ぐクライアント管理のみ）。ヘッドレス CLI 呼び出し
  （`gemini -p ...`、`copilot -p ... --allow-all-tools`）で運用する
- GitHub Copilot coding agent（非同期・クラウド実行）は GitHub MCP Server の
  `assign_copilot_to_issue` ツール、または `gh issue edit --add-assignee copilot-swe-agent`
  で起動する。投げた後は非同期で PR が立つのを待つ形で、Codex MCP のような同期応答ではない
- ローカル LLM（Ollama）は MCP 化不要。別 PC で動かし続け、`OLLAMA_HOST` をそのマシンに
  向ける運用のままでよい
- 「Codex による独立レビュー」「最終承認は人間」という原則は MCP 直結にしても維持できる
  （Codex には生の差分を渡し、生のレビュー結果をユーザーに見せる運用にすればよい）

## Prohibited Actions

- シークレット・認証情報のコミット
- 未完成・曖昧な原則のコミット（issue で管理する）
- プロジェクト固有のルールを憲章に追加すること
- ソースコード・ビルド成果物・ログのコミット
