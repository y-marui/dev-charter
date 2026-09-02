# GitHub Repository Settings (lite)

個人開発〜小規模で、`main` への直接pushを許可するプロジェクト向けの GitHub リポジトリ設定ガイド。Sponsors・CODEOWNERS・Actionsワークフロー権限など、外部コントリビューターの受け入れやOSS運用を前提とした項目は full 版の [topics/GITHUB_SETTINGS.md](https://github.com/y-marui/dev-charter/blob/full/topics/GITHUB_SETTINGS.md)（full）を参照する。

## Direct Push vs. Pull Request

lite の運用では、変更の大部分は `main` への直接pushで完結させ、一部の大きな変更だけPRを経由する。判断に迷う場合はPRを経由する側に倒す。

| 直接pushでよい | PR経由にする |
|---|---|
| 依存関係定義ファイル・設定ファイルの追従的な更新（Brewfile、lockファイルの通常更新等） | 新規スクリプトの追加、既存スクリプトの大規模な見直し・書き換え |
| ノート・メモ・コンテキストファイルの蓄積、既存ドキュメントの軽微な修正 | 新規 Agent Skill の追加、既存 Skill の大規模改修 |
| 既存 Skill・ドキュメントの軽微なブラッシュアップ、typo修正 | プロジェクト全体構造（ディレクトリ構成、AIコンテキスト階層等）に関わる refactoring |

## Branch Protection (Ruleset)

**確認場所:** GitHub リポジトリ → Settings → Rules → Rulesets

Classic branch protection（Settings → Branches）ではなく **Ruleset** を使う。既存に Classic branch protection が設定されている場合は削除し、下記の Ruleset を新規作成する（Classic と Ruleset の使い分けの詳細は full 版の [GITHUB_SETTINGS.md](https://github.com/y-marui/dev-charter/blob/full/topics/GITHUB_SETTINGS.md) の「Existing Ruleset Check」を参照）。

### Content

```
Name: main-protection
Target: main
Enforcement: Active

Rules:
☐ Require a pull request before merging   （OFFのまま。直接pushを許可する）
☑ Require status checks to pass before merging
  └ Status checks: CI (GitHub Actions)
☑ Require conversation resolution before merging
☑ Block force pushes
☑ Restrict deletions
```

`Require a pull request before merging` を **OFF** にする点が full 版との唯一の差分。それ以外の項目（ステータスチェック・会話解決・force push禁止・削除禁止）は full と同じ内容で問題ない。

### Why This Works for Both Direct Push and PRs

GitHubのRulesetは「Require a pull request before merging」がOFFでも、「Require status checks to pass before merging」は直接pushにも適用される（push しようとしているcommitに成功ステータスが記録されていなければpushをブロックする）。一方「Require conversation resolution before merging」はPRのmerge時にのみ効くルールのため、直接pushでは実質no-opになるが、開発者がPRを経由して変更を出した場合には会話解決を強制できる。

この組み合わせにより、1つの Ruleset で「直接pushは許容しつつ、PRを使う場合はCI通過・会話解決を必須にする」という中間的な運用を実現できる。

### Migration for Existing Adopters

Classic branch protection（`enforce_admins`・`required_conversation_resolution` 等）を既に設定している採用先は、上記 Ruleset への移行が別途必要になる。移行自体は本ドキュメントの適用範囲外とし、各採用先で個別に対応する。
