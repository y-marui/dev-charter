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

## Contributing Templates

OSS で外部コントリビューターを受け付ける場合、以下のファイルを追加する。

### CONTRIBUTING.md

````markdown
## How to Contribute

大きな変更（新機能・設計変更）は PR の前に issue で相談してください。
小さなバグ修正や typo は直接 PR を送っていただいて構いません。

## Development Setup

セットアップ手順は [README-jp.md](README-jp.md) を参照してください。

## Code Style

[CODE_STYLE.md](docs/dev-charter/CODE_STYLE.md) に従ってください。

## Commit Messages

[Conventional Commits](https://www.conventionalcommits.org/) 形式を使用してください（例: `fix: ...`、`feat: ...`）。

## Pull Request Checklist

- [ ] シークレット・認証情報が含まれていない
- [ ] lint が通る
- [ ] 型チェックが通る（該当する場合）
- [ ] テストが通る（該当する場合）
- [ ] ビルドが成功する（成果物がある場合）
- [ ] 新機能にはテストを追加した
- [ ] ユーザー向けの変更はドキュメントを更新した
- [ ] CHANGELOG.md の [Unreleased] セクションにエントリを追加した（該当する場合）
- [ ] 動作確認済み（該当する場合）

## Contribution Terms

By contributing, you agree that your contributions are licensed under
[AGPL v3 / GPL v3 / LGPL v3] and that you grant the project maintainer
a non-exclusive, perpetual, worldwide, royalty-free right to use, reproduce,
modify, distribute, sublicense, and relicense your contributions under any license.
````

`[AGPL v3 / GPL v3 / LGPL v3]` はプロジェクトのライセンスに合わせて置き換えること。
チェックリストの項目はプロジェクトに合わせて取捨選択すること。
AGPL/GPL/LGPL 以外のプロジェクト（MIT 等）では「Contribution Terms」セクションを省略する。

### .github/PULL_REQUEST_TEMPLATE.md

PR テンプレートは CONTRIBUTING.md のチェックリストと対応させる。
**CONTRIBUTING.md を編集した場合は PR テンプレートも合わせて見直すこと。**

````markdown
## Description

<!-- 変更内容を簡潔に説明してください -->

## Checklist

- [ ] シークレット・認証情報が含まれていない
- [ ] lint が通る
- [ ] 型チェックが通る（該当する場合）
- [ ] テストが通る（該当する場合）
- [ ] ビルドが成功する（成果物がある場合）
- [ ] 新機能にはテストを追加した
- [ ] ユーザー向けの変更はドキュメントを更新した
- [ ] CHANGELOG.md の [Unreleased] セクションにエントリを追加した（該当する場合）
- [ ] 動作確認済み（該当する場合）
- [ ] I have read and agree to the terms in CONTRIBUTING.md.
````

> **運用上の注意**: GitHub はチェックボックスの完了を強制しない。チェックなしの PR はマージしないこと。これが準 CLA の唯一の強制機構である。

AGPL/GPL/LGPL 以外のプロジェクトでは最後の CLA 同意チェックボックスを省略する。

### .github/ISSUE_TEMPLATE/

Issue テンプレートの構成項目は [Issues セクション](#issues) を参照。

### Quasi-CLA（コピーレフトプロジェクト向け）

AGPL/GPL/LGPL を採用し、将来の再ライセンスの余地を確保したい場合、外部コントリビューターから必要な許諾を事前に取得しておく。本格的な CLA サービスは導入せず、`CONTRIBUTING.md` と PR テンプレートによる **準 CLA 方式**で運用する（上記テンプレートの "Contribution Terms" セクションおよび CLA 同意チェックボックスがこれに該当する）。

#### Phased Approach

| フェーズ | 移行トリガー | 運用 |
|---|---|---|
| 初期 | — | 準 CLA（CONTRIBUTING + PR 同意）で運用 |
| 移行 | コントリビュータ 3〜5 人以上 / 継続的な外部 PR / コア機能への影響が増大 | 以降の新規コントリビューションに CLA Assistant 等の正式な CLA サービスを適用。準 CLA 設置後のコントリビュータは再同意不要（許諾は永続的かつ取消不能なため） |

コピーレフトライセンス採用後かつ準 CLA 設置前に行われたコントリビューションがある場合に限り、該当コントリビュータへの個別対応（再同意取得または未同意コードの排除・置換）が必要になる場合がある。

> **注意**: 準 CLA で取得する再ライセンス権は法的に有効だが、同意の証明力は正式 CLA より弱い。プロジェクトが成長し、訴訟リスクが現実的になった段階で正式な CLA サービスへの移行を検討すること。

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
