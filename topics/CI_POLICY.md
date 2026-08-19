# CI Policy

## Naming Convention

| 対象 | 規則 | 例 |
|---|---|---|
| ワークフローファイル名 | 機能を表す小文字 + ハイフン | `ci.yml`, `charter-check.yml` |
| ワークフロー `name` | タイトルケース、短く端的に | `CI`, `Dev Charter` |
| job ID | 小文字スネークケース | `lint`, `test`, `build` |
| job `name` | タイトルケース。追加説明が必要な場合は括弧付きで補足 | `Lint`, `Test`, `Test (pytest)`, `Build`, `Security scan (pre-commit)` |

### Standard Job Names

| job ID | `name` | 用途 |
|---|---|---|
| `security` | `Security scan (pre-commit)` | pre-commit によるシークレット検知・静的解析 |
| `lint` | `Lint` | コードスタイル・フォーマット検査 |
| `test` | `Test` / `Test (pytest)` など | ユニットテスト・インテグレーションテスト |
| `build_artifact`（任意） | `Build Artifact` | ビルド成果物の生成、またはインストール可能性の検証 |
| `build` | `Build` | 全 job の集約ゲート（後述） |

`build` は全 job の集約点として必ず最後に配置し、Branch Protection（Ruleset）の必須ステータスチェックに登録する。

## Job Design

**CIのjob構成とRuleset設定を分離し、Ruleset管理を最小化する。**

- 複数jobの場合：最後に集約ゲート `build` jobを配置し、`needs` で全依存を定義する
- 単一jobの場合：そのjobを `build` と命名する
- Ruleset設定：`build` のみ指定（全リポジトリ共通）

この方針により、jobを追加してもRulesetの変更が不要になる。

### `build` Is a Gate, Not Just a `needs` Aggregation

> **注意（過去の誤り）:** 以前このドキュメントは「いずれかの job が失敗すると `build` が
> skip され、マージ不可になる」と説明していたが、これは誤り。GitHub の Ruleset /
> Branch Protection の `required_status_checks` は、必須チェックが **`skipped` で完了した
> 場合はブロックしない**（`failure` の場合のみブロックする）。`build` が `needs: [security,
> lint, test]` のみで暗黙の `if: success()` に依存していると、依存 job が失敗したときに
> `build` 自体は `skipped` として完了し、Ruleset 上は「必須チェックを満たした」と扱われて
> **失敗したままマージできてしまう**。2026-08 に実際の運用で発覚した。

正しい実装は、`build` を **常に実行するゲート job**（`if: always()`）にし、`needs.*.result`
を明示的に検査して `failure`/`cancelled` があれば自身を `failure` として終了させる。

```yaml
build:
  name: Build
  needs: [security, lint, test]   # build_artifact 等があれば追加
  if: always()
  runs-on: ubuntu-latest   # ゲートは判定のみなので常に最安ランナーでよい
  steps:
    - name: Verify required jobs succeeded
      run: |
        for result in "${{ needs.security.result }}" "${{ needs.lint.result }}" "${{ needs.test.result }}"; do
          if [ "$result" != "success" ]; then
            echo "::error::a required job did not succeed (got: $result)"
            exit 1
          fi
        done
```

ビルド成果物の生成やインストール可能性の検証など、実体のあるビルド作業がある場合は、
それを `build` とは別の job（`build_artifact` など、job ID・`name` は自由）に切り出し、
`build` の `needs` に追加する。`build` 自体は判定専用に保ち、実作業ジョブと同じ高コストな
ランナー（`macos-latest` 等）で起動させない（[Cost Optimization](#cost-optimization-path-filtering)
参照）。

```yaml
build_artifact:
  name: Build Artifact
  needs: [security, lint, test]
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v4
    - run: pip install -e .
    - run: python -c "import mypackage"

build:
  name: Build
  needs: [security, lint, test, build_artifact]
  if: always()
  runs-on: ubuntu-latest
  steps:
    - name: Verify required jobs succeeded
      run: |
        for result in "${{ needs.security.result }}" "${{ needs.lint.result }}" "${{ needs.test.result }}" "${{ needs.build_artifact.result }}"; do
          if [ "$result" != "success" ]; then
            echo "::error::a required job did not succeed (got: $result)"
            exit 1
          fi
        done
```

**単一job：** そのjobを `build` と命名する（この場合はゲートを分離する必要はない）。

### Cost Optimization (Path Filtering)

`docs/**` や `*.md` のみの変更（例：`git subtree pull` による dev-charter 更新、README
の修正）では、`lint`/`test`/`build_artifact` のような高コストな job（特に `macos-latest`
等の高額ランナー）を実行する必要がない。

**ワークフロー単位の `paths-ignore` は使わない。** ワークフロー自体がトリガーされないと
必須ステータスチェックが一切報告されず、PR が `Expected — Waiting for status to be
reported` のまま永久にブロックされる（`build` が Ruleset の必須チェックである場合）。

代わりに [dorny/paths-filter](https://github.com/dorny/paths-filter) で変更内容を判定し、
**job-level の `if:`** で `lint`/`test`/`build_artifact` をスキップする。`security`
（pre-commit）は ubuntu-latest で安価な上、pre-commit 自身の `files:`/`types:` で
変更ファイルに応じて各フックが自動的にスキップされるため、job 単位でのフィルタは不要。

```yaml
jobs:
  changes:
    name: Detect changes
    runs-on: ubuntu-latest
    outputs:
      code: ${{ steps.filter.outputs.code }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          predicate-quantifier: 'some-with-excludes'
          filters: |
            code:
              - '**'
              - '!**/*.md'
              - '!docs/**'
              - '!LICENSE'
              - '!.gitignore'
              - '!.github/FUNDING.yml'
              - '!.github/CODEOWNERS'
              - '!.github/ISSUE_TEMPLATE/**'
              - '!.github/*_TEMPLATE.md'
              - '!.github/pull_request_template.md'
              - '!.github/copilot-instructions.md'
              - '!.github/workflows/dev-charter-check.yml'
              - '!.github/workflows/auto-assign-self.yml'

  security:
    name: Security scan (pre-commit)
    runs-on: ubuntu-latest
    # フィルタなし。pre-commit 自身が変更ファイルに応じて自動スキップする
    # ...

  lint:
    name: Lint
    needs: changes
    if: needs.changes.outputs.code == 'true'
    # ...

  test:
    name: Test
    needs: changes
    if: needs.changes.outputs.code == 'true'
    # ...

  build_artifact:
    name: Build Artifact
    needs: [changes, security, lint, test]
    if: needs.changes.outputs.code == 'true'
    # ...

  build:
    name: Build
    needs: [changes, security, lint, test, build_artifact]
    if: always()
    runs-on: ubuntu-latest
    steps:
      - name: Verify required jobs succeeded
        run: |
          if [ "${{ needs.security.result }}" != "success" ]; then
            echo "::error::security did not succeed (got: ${{ needs.security.result }})"
            exit 1
          fi
          if [ "${{ needs.changes.outputs.code }}" != "true" ]; then
            echo "docs/config-only change; nothing further to verify"
            exit 0
          fi
          for result in "${{ needs.lint.result }}" "${{ needs.test.result }}" "${{ needs.build_artifact.result }}"; do
            if [ "$result" != "success" ]; then
              echo "::error::a required job did not succeed (got: $result)"
              exit 1
            fi
          done
```

**依存ロックファイル（`uv.lock` / `package-lock.json` / `Package.resolved` 等）は
skip 対象に含めない。** ロックファイルの更新は依存パッケージのバージョン変更そのものであり、
実際に lint/test/build を回して初めて壊れていないか確認できる。Dependabot の PR を含め、
これらの変更は常にフル CI を実行する。

`Makefile` はほとんどのプロジェクトで CI から直接呼ばれない（`ci.yml` は各コマンドを直接
実行する）ため skip 対象に含めてよいが、CI が `make` 経由でビルド・テストを呼んでいる
プロジェクトでは対象から除外すること。

### Artifact Retention

| 対象 | 保持期間（目安） |
|---|---|
| PR | 短期（例：7日） |
| main | 長期（例：30日） |

## Dependabot

`.github/dependabot.yml` の導入を検討する。依存パッケージがあるプロジェクトでは自動でアップデートPRを作成し、脆弱性対応を省力化できる。ドキュメントのみのリポジトリや依存パッケージが存在しないプロジェクトでは不要。

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
  └ Status checks: Build (GitHub Actions)
☑ Require conversation resolution before merging
☑ Block force pushes
☑ Restrict deletions
```

### Bypass for Billing-Blocked CI (Private Repos, Provisional)

Private リポジトリは GitHub Actions の課金対象（Public リポジトリは無料）。開発リソースが
限られる個人開発では、支払い方法・spending limit の問題で CI が丸ごと失敗し、必須チェック
がブロックされたままになることがある（`~/.ai/AI_CONTEXT.md` の GitHub セクションに同様の
運用メモあり：課金エラーによる CI 失敗はコード側の問題ではないため無視してよい）。

暫定処置として、Private リポジトリの `main-protection` Ruleset に **Repository admin の
bypass（PR 経由のみ）** を追加してよい（Ruleset の `bypass_actors` に以下を追加）：

```json
{
  "actor_id": 5,
  "actor_type": "RepositoryRole",
  "bypass_mode": "pull_request"
}
```

- `actor_id: 5` は Repository admin ロール（個人リポジトリでは実質オーナー本人）
- `bypass_mode: "pull_request"` — 直接 push は引き続き禁止。PR 経由でのマージ時のみ
  必須チェックをバイパスできる（`"always"` にはしない）
- Public リポジトリには適用しない（CI が無料で課金ブロックが起きないため不要）
- ローカルで `pre-commit run` 等により変更内容を確認済みの場合のみ使う。CI が本当に
  コードの問題で落ちているときの緊急回避には使わない
- 設定は GitHub の Settings → Rules → Rulesets（または `gh api` で既存 Ruleset 全体を
  取得し、`bypass_actors` だけを差し替えて `PUT` する）から行う。既存フィールドを
  壊さないよう、必ず現在の Ruleset 定義を取得してから更新すること

### Status Check Configuration

Rulesetの「Require status checks to pass before merging」でチェックを追加する際は、**名前とソースの両方を正しく指定**する。

**チェック名：**
GitHub Actions のステータスチェック名は、job の **`name` フィールドの値**（`Build`）で決まる。
job ID（`build`）ではないため注意。

```yaml
jobs:
  build:
    name: Build   # ← Rulesetに登録する名前はこの値
```

job `name` を省略した場合は job ID がチェック名になる（例：`build`）。

**ソース（Source）：**
チェック名を入力後、**ソースを `GitHub Actions` に指定する**（"Any source" のままにしない）。
"Any source" にすると、他の外部 CI サービスや手動操作でも条件を満たせてしまう。

Rulesetの設定画面では以下のように表示される：

```
Check name:  Build
Source:      GitHub Actions
```

集約 job の `name` は説明を追加せず、常に `Build` とする。個別 job の表示名は必要に応じて説明を追加してよい。
