# Charter Index (lite)

dev-charter lite 版のドキュメント索引。プロジェクト種別を問わず
普遍的に価値がある部分だけを収録している。full 版の全体像は
https://github.com/y-marui/dev-charter を参照。

## Install

まだ導入していない場合、プロジェクトのルートで以下のいずれかを実行する：

```bash
# Quick Install
CHARTER_BRANCH=lite bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

```
# git subtree で直接導入する場合
git remote add dev-charter https://github.com/y-marui/dev-charter
git fetch dev-charter
git subtree add --prefix=docs/dev-charter dev-charter lite --squash
```

導入後、以下のプロンプトを AI ツールに貼り付ける：

```
docs/dev-charter/CHARTER_INDEX.md を読み、AI_CONTEXT.md と AI ツール設定ファイルを生成して
```

## Updating

`docs/dev-charter/` は git subtree で導入されている。更新するには：

```
git remote add dev-charter https://github.com/y-marui/dev-charter  # 未追加の場合のみ
git subtree pull --prefix=docs/dev-charter dev-charter lite --squash
```

`main`/`lite` の取り違えを防ぐには、このファイルの `(lite)` マーカーで
導入済みブランチを自動判定する Makefile ヘルパーを使う（full 版 README の
"Makefile helper" セクション参照）。

更新後は `git diff HEAD~1 HEAD --name-only -- docs/dev-charter/` で
変更ファイルを確認し、プロジェクトへの影響を反映する（lite にはローカルの
UPDATE_CHECKLIST.md がないため、必要なら full 版を参照：
https://github.com/y-marui/dev-charter/blob/main/UPDATE_CHECKLIST.md ）。

## Index

| トピック / キーワード | ファイル |
|---|---|
| AI の作業前チェック、エラー対処、AI 役割分担、複数 AI 連携、ローカル LLM、Ollama | `AI_COLLABORATION_RULES.md` |
| AI コンテキストの優先順位（タスク > プロジェクト > 憲章 > グローバル） | `AI_CONTEXT_HIERARCHY.md` |
| CLAUDE.md・GEMINI.md・AGENTS.md・AI_CONTEXT.md の構成方法 | `AI_TOOL_SETUP.md` |
| docs/ 構成、file-map.md、architecture.md、AI_CONTEXT.md 参照順、CONTRIBUTING.md | `DOCS_STRUCTURE.md` |
| シークレット管理、git フック、pre-commit、セキュリティ設定 | `SECURITY_POLICY.md` |
| TODO・バックログ・ロードマップ管理、Issues、Sub-issues、Milestones、Projects (v2) | `topics/GITHUB_PROJECT_MANAGEMENT.md` |
