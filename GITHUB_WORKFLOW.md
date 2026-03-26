# GitHub Workflow

## Repository Hosting

- コード管理には **GitHub** を使用する（`github.com`）
- デフォルトブランチは `main`

## Issues

GitHub Issueでバグ・機能要望を管理する。

### Bug Report

バグレポートには以下を含める：

- 再現手順（最小限）
- 期待する動作
- 実際の動作
- 環境情報（OS、言語・FWバージョン等）

### Feature Request

フィーチャーリクエストには以下を含める：

- 解決したい問題・ユースケース
- 提案する解決策
- 代替案（あれば）

## Pull Requests

- コードの変更はすべてPR経由でマージする（`main` への直接pushは禁止）
- PRタイトルはConventional Commits形式（`feat:` / `fix:` / `docs:` 等）
- 関連Issueはdescriptionで参照する（`closes #123`）
- マージ条件：全会話解決済み・CI通過
- レビュー承認数はプロジェクト規模に応じて設定する（個人開発：0、複数人：1以上）

## CI Policy

### 基本方針

**CIのjob構成とRuleset設定を分離し、Ruleset管理を最小化する。**

- 複数jobの場合：最後に `build` jobを配置し、`needs` で全依存を定義する
- 単一jobの場合：そのjobを `build` と命名する
- Ruleset設定：`build` のみ指定（全リポジトリ共通）

この方針により、jobを追加してもRulesetの変更が不要になる。

### Job構成パターン

**複数job（推奨）：**

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:

jobs:
  security:
    name: Security scan
    # ...

  lint:
    name: Lint
    # ...

  test:
    name: Test
    # ...

  build:
    name: Build
    needs: [security, lint, test]
    # ...
```

`build` が全jobの集約点となる。いずれかが失敗すると `build` がskipされ、マージ不可になる。

**単一job：** そのjobを `build` と命名する。

**ビルド成果物が存在しない場合（純粋なライブラリ等）：** `build` jobでインストール可能性を検証する。

```yaml
build:
  name: Installability check
  needs: [security, lint, test]
  steps:
    - uses: actions/checkout@v4
    - run: pip install -e .
    - run: python -c "import mypackage"
```

### Artifact Retention

| 対象 | 保持期間（目安） |
|---|---|
| PR | 短期（例：7日） |
| main | 長期（例：30日） |

## Branch Protection (Ruleset)

`main` ブランチに以下のRulesetを適用する（全リポジトリ共通）：

```
Name: main-protection
Target: main
Enforcement: Active

Rules:
☑ Require a pull request before merging
  └ Required approvals: 0（個人開発）/ 1以上（複数人）
☑ Require status checks to pass before merging
  └ Status checks: build
☑ Require conversation resolution before merging
☑ Block force pushes
☑ Restrict deletions
```

---

*このドキュメントには英語版 [README.md](README.md) があります。編集時は同一コミットで更新してください。*
