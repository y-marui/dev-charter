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

> **注意:** 「Require a pull request before merging」を OFF にしたまま「Require status checks to pass before merging」を ON にする構成は使えない。新規にpushするcommitはpush時点でまだそのSHAに対する成功ステータスが存在しないため、直接pushそのものがブロックされてしまう（`push` トリガーのCIも、ステータスが記録されるのはpush受理後になるため間に合わない）。「direct push許容」と「必須ステータスチェック」は、下記のようにbypass actorを使わない限り両立しない。

### Content

full 版と同じ内容の Ruleset を作成した上で、リポジトリオーナー（実質1名の個人開発を想定）だけを bypass actor として登録する。これにより、通常は full と同じ「PR必須・CI必須・会話解決必須」が適用されるが、オーナーは直接pushを含めて随時バイパスできる。

```
Name: main-protection
Target: main
Enforcement: Active

Rules:
☑ Require a pull request before merging
  └ Required approvals: 0
☑ Require status checks to pass before merging
  └ Status checks: CI (GitHub Actions)
  └ Status checks: Dev Charter (GitHub Actions)   ← dev-charter-check.yml を導入している場合
☑ Require conversation resolution before merging
☑ Block force pushes
☑ Restrict deletions

Bypass list:
  Repository admin — Bypass mode: Always
```

full 版との差分は **bypass actor（Repository admin, mode: Always）を追加する点のみ**。それ以外のルール項目は full と同じ内容で問題ない。

```json
{
  "actor_id": 5,
  "actor_type": "RepositoryRole",
  "bypass_mode": "always"
}
```

`actor_id: 5` は Repository admin ロール（個人リポジトリでは実質オーナー本人）。`bypass_mode: "always"` は「PRを経由しない直接pushを含め、この Ruleset のあらゆる制約を常にバイパスできる」ことを意味する（full 版の [CI_POLICY.md](https://github.com/y-marui/dev-charter/blob/full/topics/CI_POLICY.md) にある `bypass_mode: "pull_request"`（PR経由のマージ時のみ必須チェックをバイパスできるが直接pushは引き続き禁止）とは異なる点に注意）。

### Why a Bypass Actor Is Necessary

Ruleset自体には「直接pushは許可しつつ、PRを使う場合だけCI/会話解決を必須にする」という中間モードは存在しない。「Require a pull request before merging」はON/OFFの二択で、OFFにすると他のルールごと直接pushへの制約も一緒に緩んでしまうわけではなく（`Require status checks` は直接pushにも適用され続ける）、むしろ「新規commitに事前の成功ステータスが無い」ことでpush自体が拒否される（上記の注意参照）。

そのため、ルール自体は full と同じ「PR必須・CI必須・会話解決必須」のまま維持し、**オーナーだけをbypass actorにする**ことで「オーナーは直接pushも自由にできるが、それ以外（将来の共同作業者・Dependabot・`update-charter` 自動PR等）には full と同じ制約が適用される」という状態を作る。オーナー自身がPRを経由する場合も、bypass権限により会話解決・CI未通過のままマージすることは技術的には可能だが、通常は上表の判断基準に従い、大きな変更ではCIグリーンを確認してからマージする運用とする。

### Migration for Existing Adopters

Classic branch protection（`enforce_admins`・`required_conversation_resolution` 等）を既に設定している採用先は、上記 Ruleset（PR必須 + オーナーのbypass actor登録）への移行が別途必要になる。移行自体は本ドキュメントの適用範囲外とし、各採用先で個別に対応する。
