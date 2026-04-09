# GitHub Repository Settings

GitHub リポジトリ設定の確認ガイド。テンプレートからプロジェクトを作成したとき、または新規リポジトリをセットアップする際に使用する。

## Branch Protection (Ruleset)

[topics/CI_POLICY.md](CI_POLICY.md) で定義した Ruleset が正しく設定されているか確認する。

**確認場所:** GitHub リポジトリ → Settings → Rules → Rulesets

### Existing Ruleset Check

既存の設定状態に応じて対応が異なる：

| 状態 | 対応 |
|---|---|
| `main-protection` が存在する | 下記チェックリストで内容を確認する |
| 別名（`main`・`branch-protection` 等）の Ruleset が存在する | `main-protection` に改名し、内容を確認する |
| Classic branch protection が設定されている | 削除して `main-protection` Ruleset を新規作成する（Classic は機能が限定的） |
| 何も設定されていない | `main-protection` Ruleset を新規作成する |

> **Classic branch protection について:** GitHub の旧来の "Branch protection rules"（Settings → Branches）は機能が限定的で、Ruleset への移行が推奨される。Classic と Ruleset が両方設定されている場合は Classic を削除して Ruleset に一本化する。

### Content Checklist

`main-protection` Ruleset の内容を確認する：

```
Name: main-protection
Target: main
Enforcement: Active  ← Active になっているか確認（Evaluate / Disabled は機能しない）

Rules:
☑ Require a pull request before merging
  └ Required approvals: 0（個人開発）/ 1 以上（複数人）
☑ Require status checks to pass before merging
  └ Status checks: Build (GitHub Actions)  ← job name と GitHub Actions ソースを確認
     ※ job name に説明がある場合は "Build (installability check)" 等、実際の名前で登録する
☑ Require conversation resolution before merging
☑ Block force pushes
☑ Restrict deletions
```

> **Status check の名前とソースについて：** job `name` フィールドの値（例：`Build`）がチェック名になる。ソースは `GitHub Actions` を指定する（`Any source` にしない）。詳細は [topics/CI_POLICY.md](CI_POLICY.md) を参照。

## Actions: Workflow permissions

**確認場所:** GitHub リポジトリ → Settings → Actions → General → Workflow permissions

### Workflow permissions（デフォルト権限）

| 設定値 | 意味 |
|---|---|
| Read and write permissions | ワークフローがリポジトリへの書き込みを許可（プッシュ・PR作成など） |
| Read repository contents and packages permissions | 読み取り専用（デフォルト） |

`update-version.yml` でVERSIONファイルをコミット・プッシュする場合は **Read and write permissions** が必要。ただし workflow ファイル内で `permissions: contents: write` を明示的に指定すれば、リポジトリレベルのデフォルトが Read only のままでも動作する（個別指定が優先されるため）。

### Allow GitHub Actions to create and approve pull requests

このチェックボックスは **デフォルトで OFF**。`gh pr create` 等でPRを作成するワークフローを使う場合は **ON にする必要がある**。

| リポジトリで使用するワークフロー | 設定 |
|---|---|
| `check-charter.yml`（dev-charterの自動更新PR作成）を使う | **ON** |
| PRを作成・承認するワークフローが存在しない | OFF のまま |

> **設定がリポジトリごとにバラバラになりがちな理由：** この設定はリポジトリ作成時に自動で有効化されず、ワークフロー追加時に手動で設定が必要なため。`check-charter.yml` を導入する際は必ず本設定を確認すること。

## Sponsors (FUNDING.yml)

GitHub Sponsors の設定状態はリポジトリの種別（テンプレート / プロジェクト）によって異なる。

| リポジトリ種別 | Features: Sponsorships | `.github/FUNDING.yml` の状態 | Sponsor ボタン |
|---|---|---|---|
| テンプレートリポジトリ | OFF | `[USERNAME]` プレースホルダーのまま | 非表示（意図的） |
| プロジェクトリポジトリ | ON | 実際のユーザー名に置換済み | 表示される |

### Template Repository

- `.github/FUNDING.yml` に `[USERNAME]` が残っている状態でよい
- Settings → Features → Sponsorships は OFF のまま（プロジェクト側で設定する）

### Project Repository

テンプレートからプロジェクトを作成した段階で、以下を両方実施する：

**1. GitHub リポジトリ設定で Sponsorships を有効化**

Settings → Features → Sponsorships にチェックを入れる。

**2. FUNDING.yml のプレースホルダーを置換**

- [ ] `.github/FUNDING.yml` の `[USERNAME]` を実際の GitHub ユーザー名（および Buy Me a Coffee のユーザー名）に置き換えた
- [ ] リポジトリページの右カラムに「Sponsor」ボタンが表示されている

```yaml
# Before（テンプレート）
github: [USERNAME]
buy_me_a_coffee: [USERNAME]

# After（プロジェクト）
github: your-github-username
buy_me_a_coffee: your-buymeacoffee-username
```

**Settings の Sponsorships と FUNDING.yml の両方が必要。** どちらか片方だけでは Sponsor ボタンが表示されない。

FUNDING.yml の詳細は [MONETIZATION_POLICY.md](../MONETIZATION_POLICY.md) を参照。
