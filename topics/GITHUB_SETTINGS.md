# GitHub Repository Settings

GitHub リポジトリ設定の確認ガイド。テンプレートからプロジェクトを作成したとき、または新規リポジトリをセットアップする際に使用する。

## Branch Protection (Ruleset)

[topics/CI_POLICY.md](CI_POLICY.md) で定義した Ruleset が正しく設定されているか確認する。

**確認場所:** GitHub リポジトリ → Settings → Rules → Rulesets

```
Name: main-protection
Target: main
Enforcement: Active  ← Active になっているか確認

Rules:
☑ Require a pull request before merging
  └ Required approvals: 0（個人開発）/ 1 以上（複数人）
☑ Require status checks to pass before merging
  └ Status checks: build  ← build が追加されているか確認
☑ Require conversation resolution before merging
☑ Block force pushes
☑ Restrict deletions
```

**Enforcement が "Evaluate" または "Disabled" のままだと保護が機能しない。** 必ず "Active" に設定すること。

Ruleset の仕様は [topics/CI_POLICY.md](CI_POLICY.md) を参照。

## Sponsors (FUNDING.yml)

GitHub Sponsors の設定状態はリポジトリの種別（テンプレート / プロジェクト）によって異なる。

| リポジトリ種別 | `.github/FUNDING.yml` の状態 | Sponsor ボタン |
|---|---|---|
| テンプレートリポジトリ | `[USERNAME]` プレースホルダーのまま | 非表示（意図的） |
| プロジェクトリポジトリ | 実際のユーザー名に置換済み | 表示される |

### Template Repository

`.github/FUNDING.yml` に `[USERNAME]` が残っている状態でよい。テンプレートから作成したプロジェクト側で置換する。

### Project Repository

テンプレートからプロジェクトを作成した段階で、以下を確認・実施する：

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

**置換しないとリポジトリに Sponsor ボタンが表示されない。** プロジェクト公開時に必ず確認すること。

FUNDING.yml の詳細は [MONETIZATION_POLICY.md](../MONETIZATION_POLICY.md) を参照。
