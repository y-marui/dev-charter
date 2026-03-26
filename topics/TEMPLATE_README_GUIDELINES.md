# GitHub Template Repository Guidelines

このドキュメントは、**GitHub でテンプレートリポジトリを新規作成する際**に固有の手順・規約を定める。

他の憲章ドキュメント（`LANGUAGE_POLICY.md` 等）が複数プロジェクト横断の普遍的原則を定めるのに対し、このドキュメントは「テンプレートリポジトリの README をどう構成するか」「どのファイルを含めるか」といった、テンプレート作成という特定の操作に限定した個別ガイドである。テンプレートに適用されるポリシーそのもの（言語ポリシー・ライセンス等）は各専門ドキュメントを参照すること。

テンプレートから作成した**プロジェクト側**の README については [PROJECT_README_GUIDELINES.md](PROJECT_README_GUIDELINES.md) を参照すること。

---

## 1. Definition of Development Scope

テンプレートリポジトリを作成する前に、以下を明記する。

| 項目 | 定義すべき内容 | 例 |
|---|---|---|
| 対象プラットフォーム | どの環境向けのテンプレートか | iOS app / Python package / Chrome extension |
| 技術スタック | 使用言語・FW・最低バージョン | Swift 5.9 / iOS 17 / SwiftUI |
| テンプレートの用途 | このテンプレートから何を作るか | 個人向け iOS アプリの雛形 |
| ビルド成果物 | 成果物の有無と形式 | あり（.app / .ipa / .whl / .alfredworkflow 等）/ なし |

これらを `README-jp.md` のメタ情報テーブルに記載することで、利用者がテンプレートの用途を一目で判断できるようにする。

### 1.1 Project Type Reference

典型的なプロジェクト種別と、それぞれの配布形態・ライセンス・マネタイズの傾向を示す。ライセンスとマネタイズの詳細は §4 と [MONETIZATION_POLICY.md](../MONETIZATION_POLICY.md) を参照すること。

| プロジェクト種別 | 配布形態 | 典型的なライセンス | マネタイズ |
|---|---|---|---|
| Mac app / iOS app | App Store・直接配布（バイナリ） | Closed または AGPL/GPL/LGPL | Sublime Text 方式 |
| Chrome 拡張 | Chrome Web Store（バイナリ相当） | Closed または AGPL/GPL/LGPL | Buy Me a Coffee |
| Alfred workflow | Alfred Gallery・GitHub（ソースコード） | Closed（配布しない）または MIT | 要検討 |
| Web app / site | ブラウザアクセス（配布なし） | Closed | Buy Me a Coffee ＋ 可能なら広告 |
| Python library / app | PyPI・GitHub（ソースコード） | Closed（配布しない）または MIT | 要検討 |

> GitHub 上で公開する場合は上記に加えて GitHub Sponsors を追加（[MONETIZATION_POLICY.md](../MONETIZATION_POLICY.md) 参照）。ライセンス選択は case by case であり、この表は傾向の参考にとどめる。

---

## 2. Definition of Development Environment

### 2.1 Team Structure

テンプレートリポジトリの `README-jp.md` に以下を明記する。

| 項目 | 選択肢 | 記載方法 |
|---|---|---|
| 規模 | 個人 / 小規模チーム（1〜3人）/ OSS（メンテナ複数）/ 受託 | メタ情報テーブルの「開発環境」欄 |
| 意思決定 | 個人完結 / チーム合議 | 体制が複数人の場合のみ記載 |

### 2.2 AI Tools

テンプレートが AI 支援開発を前提とする場合、使用する AI ツールとその役割をリポジトリに明示する。

**記載場所:** `AI_CONTEXT.md` の「AI Tool Assignments」セクション、および `README-jp.md` のメタ情報テーブル（オプション行）

| AI ツール | 標準的な役割 |
|---|---|
| Claude Code | 構成変更・大規模実装・アーキテクチャ設計 |
| GitHub Copilot | 細かな実装補助・テスト作成・typo 修正 |
| Gemini CLI | ドキュメント生成・翻訳補助（手動呼び出し） |

AI ツールを使用しない場合は「なし」と明記する。使用するツールのみ記載し、未使用ツールは省略する。

### 2.3 Software & Tools

開発に必要なソフトウェアは `README-jp.md` の「動作要件」または「クイックスタート」に記載する。

**必須記載事項:**
- IDE・エディタ（バージョン指定）
- ランタイム・SDK（例: Xcode 15+、Python 3.11+）
- パッケージマネージャ（例: Homebrew、pip / uv、npm / yarn）
- セキュリティフック（pre-commit を使用する場合）

---

## 3. Language Policy

テンプレートリポジトリの言語は [LANGUAGE_POLICY.md](../LANGUAGE_POLICY.md) に従う。テンプレート固有の追加ルールを以下に定める。

### 3.1 Document Language

プロジェクト種別によらず**日本語が正本・英語が参照**（`README-jp.md` が正本、`README.md` が参照）。OSS の場合、参照版（英語）には README・API 説明・エラーメッセージ等の公開向けコンテンツを英語で記載すること。（LANGUAGE_POLICY.md `## Basic Principles` / `### Language by Project` 参照）

**セクションヘッダ**: 日本語文書でも英語で記載する。（LANGUAGE_POLICY.md `## Basic Principles` 参照）

### 3.2 Language in Code

| 対象 | ルール |
|---|---|
| 識別子（変数名・関数名・クラス名） | 英語のみ |
| コードコメント | 主言語（日本語 or 英語）に統一 |
| コミットメッセージ | 英語（Conventional Commits 形式） |
| Issue / PR タイトル | 日本語可（クローズド）/ 英語推奨（OSS） |

---

## 4. License

### 4.1 Required LICENSE File

すべてのテンプレートリポジトリに `LICENSE` ファイルを含める。ライセンスなしでの公開は禁止。

### 4.2 License Selection Criteria

ライセンスは **Closed / AGPL・GPL・LGPL / MIT** の3分類から選択する。OSS だからといって必ずしも MIT ではない。

| プロジェクト種別 | 推奨ライセンス | 備考 |
|---|---|---|
| 研究・実験系（配布しない） | Closed | All Rights Reserved |
| 研究・実験系（配布する） | MIT | 制限なく利用できるよう MIT を基本とする |
| コンパイル配布系（Swift アプリ・Chrome 拡張など） | Closed または AGPL/GPL/LGPL | 将来の再ライセンスの余地を確保したい場合は準 CLA 対応を推奨（§4.6 参照） |
| ソースコードで配布系（Alfred、Python など） | Closed（配布しない）または MIT | |
| 配布なし（Web app） | Closed | API ドキュメントのみ公開も選択肢 |
| 商用利用を制限したいドキュメント系 | CC BY-NC 4.0 など | ドキュメント系テンプレートに限る |

ライセンス選択は case by case。上記は傾向の参考にとどめ、プロジェクトの状況に応じて判断すること。

### 4.3 All Rights Reserved Template

クローズドプロジェクト向けには以下の形式を `LICENSE` ファイルとして使用する。

```
Copyright (c) [YEAR] [AUTHOR]

All rights reserved.

This software and associated documentation files are proprietary and
confidential. Unauthorized copying, distribution, modification, or use
of this software, in whole or in part, is strictly prohibited without
the express written permission of the author.
```

### 4.4 MIT Template

OSS テンプレートには以下の形式を使用する。

```
MIT License

Copyright (c) [YEAR] [AUTHOR]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### 4.5 AGPL / GPL / LGPL Template

コンパイル配布系プロジェクトで、コピーレフトライセンスを採用する場合に使用する。

**ライセンス本文は公式ソースから取得すること：**

- AGPL v3: https://www.gnu.org/licenses/agpl-3.0.txt
- GPL v3: https://www.gnu.org/licenses/gpl-3.0.txt
- LGPL v3: https://www.gnu.org/licenses/lgpl-3.0.txt

取得したテキストをそのまま `LICENSE` ファイルとして配置する。

**選択の目安：**

| ライセンス | 用途 |
|---|---|
| AGPL v3 | Web サービス・SaaS 等、サーバサイドでの使用にもコピーレフトを及ぼしたい場合 |
| GPL v3 | スタンドアローンアプリ等、配布バイナリにコピーレフトを及ぼしたい場合 |
| LGPL v3 | ライブラリ等、リンクするコードへの影響を最小化したい場合 |

将来的な再ライセンスの余地を確保したい場合は **§4.6 の準 CLA 対応**を行う。

### 4.6 Quasi-CLA for Copyleft Projects

AGPL/GPL/LGPL を採用し、将来の再ライセンスの余地を確保したい場合、外部コントリビューターから必要な許諾を事前に取得しておく。本格的な CLA サービスは導入せず、`CONTRIBUTING.md` と PR テンプレートによる **準 CLA 方式**で運用する。

#### Required Files

**`CONTRIBUTING.md`**

コントリビューションの条件を明示するファイル。以下の条項を含める：

```text
By contributing, you agree that your contributions are licensed under
[AGPL v3 / GPL v3 / LGPL v3] and that you grant the project maintainer
a non-exclusive, perpetual, worldwide, royalty-free right to use, reproduce,
modify, distribute, sublicense, and relicense your contributions under any license.
```

`[AGPL v3 / GPL v3 / LGPL v3]` はプロジェクトのライセンスに合わせて置き換えること。

**`.github/PULL_REQUEST_TEMPLATE.md`**

PR テンプレートに以下のチェックボックスを追加し、明示的同意のログを残す：

```markdown
- [ ] I have read and agree to the terms in CONTRIBUTING.md.
```

**`README.md` / `README-jp.md`（任意）**

CONTRIBUTING.md への参照を追記する：

```
See CONTRIBUTING.md for contribution terms.
```

#### Phased Approach

| フェーズ | 移行トリガー | 運用 |
|---|---|---|
| 初期 | — | 準 CLA（CONTRIBUTING + PR 同意）で運用 |
| 移行 | コントリビュータ 3〜5 人以上 / 継続的な外部 PR / コア機能への影響が増大 | CLA Assistant 等の正式な CLA サービスへ移行 |

移行時は既存コントリビュータの再同意取得と、未同意コードの排除または置換が必要になる。

> **注意**: 準 CLA は法的に完全ではない。プロジェクトが成長した段階で正式な CLA サービスへの移行を検討すること。

---

## 5. README Standards

### 5.1 Required Files

| ファイル | 必須 | 内容 |
|---|---|---|
| `README-jp.md` | ✅ | 日本語版（正本） |
| `README.md` | ✅ | 英語版（参照） |
| `LICENSE` | ✅ | §4 に従ったライセンス |
| `.gitignore` | ✅ | 言語・OS・IDE に合わせた無視パターン |
| `AI_CONTEXT.md` | AI 対応時 | AI ツール向けコンテキスト |
| `CLAUDE.md` | Claude Code 使用時 | `@AI_CONTEXT.md` を記載 |
| `GEMINI.md` | Gemini CLI 使用時 | `@AI_CONTEXT.md` を記載 |
| `.github/copilot-instructions.md` | Copilot 使用時 | `AI_CONTEXT.md` を参照する旨を記載 |
| `.github/workflows/ci.yml` | CI 使用時 | テスト・ビルド・リントの自動実行 |
| `.github/FUNDING.yml` | GitHub 公開プロジェクト | GitHub Sponsors・Buy Me a Coffee の設定（[MONETIZATION_POLICY.md](../MONETIZATION_POLICY.md) 参照） |
| `CONTRIBUTING.md` | OSS で外部 PR を受け付ける場合 | コントリビューション条件の明示。AGPL/GPL/LGPL プロジェクトは準 CLA 条項を含める（§4.6 参照） |
| `.github/ISSUE_TEMPLATE/` | OSS で外部 Issue を受け付ける場合 | バグ報告・機能要望テンプレート |
| `.github/PULL_REQUEST_TEMPLATE.md` | OSS で外部 PR を受け付ける場合 | PR チェックリスト。AGPL/GPL/LGPL プロジェクトは CONTRIBUTING.md への同意チェックボックスを追加（§4.6 参照） |

### 5.2 Required README Sections (Follow Order)

1. **タイトル** — `# [技術名] [種類] Template` の形式
2. **言語宣言** — 正本・参照の宣言（[LANGUAGE_POLICY.md](../LANGUAGE_POLICY.md) `### When Using Separate Files` 参照）
3. **バッジ** — ライセンスバッジ必須 ＋ CI バッジ（GitHub Actions がある場合のみ）（§5.3 参照）
4. **メタ情報テーブル** — 開発対象・開発環境・主言語・ライセンス（+ オプション: AI ツール・動作環境）
5. **一行概要** — 「[技術スタック]で[開発対象]を作るためのテンプレート。[開発環境]向け。」
6. **特徴** — 5〜8 項目、`✅` チェックマーク必須、技術名は具体的に
7. **クイックスタート** — `git clone` から始め、環境構築コマンドまで
8. **コマンド一覧** — `make` / `npm run` / `invoke` 等、管理コマンドが 3 つ以上ある場合
9. **プロジェクト構造** — `tree` コマンドベース、3 階層まで、主要ディレクトリにコメント
10. **ドキュメント索引** — `docs/` 配下にドキュメントが存在する場合。ドキュメントのない規模のプロジェクトは省略可。
11. **ライセンス** — ライセンス名と `LICENSE` ファイルへのリンク

### 5.3 Badge Format

バッジは**言語宣言の直後**（§5.2 位置 3）に配置する。テンプレートリポジトリ固有の URL・ライセンス種別に合わせて記述すること。

**CI バッジ:**

```
[![CI](https://github.com/{user}/{repo}/actions/workflows/{workflow}.yml/badge.svg)](https://github.com/{user}/{repo}/actions/workflows/{workflow}.yml)
```

`{user}` / `{repo}` / `{workflow}` をこのテンプレートリポジトリの値に置き換える。ワークフローファイルが複数ある場合はメインの CI ワークフローのみ掲載する。

**ライセンスバッジ（§4 のライセンス選択に対応する行を使用）:**

| ライセンス | バッジ |
|---|---|
| MIT | `[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)` |
| All Rights Reserved | `[![License: All Rights Reserved](https://img.shields.io/badge/License-All%20Rights%20Reserved-red.svg)](LICENSE)` |
| AGPL v3 | `[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](LICENSE)` |
| GPL v3 | `[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)` |
| LGPL v3 | `[![License: LGPL v3](https://img.shields.io/badge/License-LGPL_v3-blue.svg)](LICENSE)` |
| CC BY-NC 4.0 | `[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](LICENSE)` |

ライセンスバッジのリンク先は常にリポジトリルートの `LICENSE` ファイル。

### 5.4 Conditional Sections

以下のセクションは条件を満たす場合のみ追加する。

| セクション | 挿入条件 | 挿入位置 |
|---|---|---|
| 動作要件 | 複数プラットフォーム、または依存関係が 3 つ以上 | 「特徴」の直後 |
| インストール | ビルド成果物あり + OSS 公開、またはストア・ギャラリー配布（App Store / Chrome Web Store / Alfred Gallery 等）がある場合 | 「一行概要」の直後 |
| 使い方 | CLI・ライブラリ・拡張機能等でコマンド体系または API 使用例がある | 「クイックスタート」の直後 |
| カスタマイズ手順 | 初回セットアップで必須の編集がある | 「ドキュメント索引」の直後 |
| AI 支援開発 | Claude Code / Copilot を使用 + `AI_CONTEXT.md` が存在 | 「ドキュメント索引」の直後 |
| リリース手順 | ビルド成果物あり + 配布プロセスがある | 「ライセンス」の直前 |

### 5.5 Information Gathering When AI Generates README

AI は README 生成前に以下を確認する。情報が不足している場合は推測せずユーザーに質問すること。
既存ファイル（`Package.swift`、`pyproject.toml` 等）から判定可能な項目は自動入力してよい。

```
README 生成に必要な情報を教えてください:
1. 開発対象: [iOS app / Python package / Chrome extension 等]
2. 開発環境: [個人 / 小規模チーム(1-3人) / OSS / 受託]
3. 主言語: [日本語 / 英語]
4. リポジトリ名: [例: swift-app-template]
5. 技術スタック: [例: Swift 5.9 / iOS 17 / SwiftUI]
6. ビルド成果物: [あり(.app / .ipa / .whl / .alfredworkflow / .zip 等) / なし]
7. AI 対応: [Claude Code / GitHub Copilot / なし]
```

### 5.6 Validation Checklist

README 作成後、以下を確認する。

```
[ ] 必須セクション（§5.2）が全て存在し、順序通りか
[ ] 言語宣言が主言語（日本語 / 英語）と一致しているか
[ ] セクションヘッダが英語か（日本語文書でも）
[ ] CI バッジの URL がこのテンプレートリポジトリを指しているか
[ ] ライセンスバッジが §4 のライセンス選択と一致しているか
[ ] メタ情報テーブルに開発対象・開発環境・主言語・ライセンスの 4 フィールドがあるか
[ ] 特徴セクションが 5〜8 項目か
[ ] プロジェクト構造にコメントが付いているか
[ ] ドキュメント索引のリンクが実在するファイルを指しているか（ドキュメントのない規模のプロジェクトはセクションごと省略）
[ ] LICENSE ファイルが存在し、README からリンクされているか
[ ] AGPL/GPL/LGPL を採用した場合、`CONTRIBUTING.md` に準 CLA 条項があり、`.github/PULL_REQUEST_TEMPLATE.md` に同意チェックボックスがあるか（§4.6）
[ ] GitHub 公開プロジェクトの場合、`.github/FUNDING.yml` が存在するか
[ ] 日本語版・英語版が同一コミットで更新されているか
[ ] bilingual 文書の末尾に編集ルールフッターがあるか
[ ] 変数の置換漏れ（[user]、[repo]、[YEAR]、[AUTHOR] 等）がないか
```

---

## 6. Steps to Create a Template Repository

1. GitHub で **"New repository"** → **"Template repository"** にチェックを入れる
2. §1 に従い開発対象・技術スタックを決定する
3. §2 に従い開発環境・AI ツール・使用ソフトウェアを定義する
4. §3 に従い言語ポリシーを決定する
5. §4 に従い `LICENSE` ファイルを作成する。AGPL/GPL/LGPL を採用する場合は §4.6 の準 CLA 対応（`CONTRIBUTING.md` + PR テンプレートへの同意チェックボックス）も行う
6. §5 に従い `README-jp.md`（日本語正本）と `README.md`（英語版）を作成する
7. AI 対応の場合は `AI_CONTEXT.md`・`CLAUDE.md`・`GEMINI.md` を作成する
8. `.github/copilot-instructions.md` を作成する（Copilot 使用時）
9. GitHub 公開プロジェクトの場合は `.github/FUNDING.yml` を作成する（[MONETIZATION_POLICY.md](../MONETIZATION_POLICY.md) 参照）
