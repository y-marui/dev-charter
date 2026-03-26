# Project README Guidelines

テンプレートから作成したプロジェクトの README に含めるべき内容を定める。
主に AI ツールが参照し、README の作成・更新時の判断基準として使用する。

テンプレートリポジトリ自体の README 設計は [TEMPLATE_README_GUIDELINES.md](TEMPLATE_README_GUIDELINES.md) を参照。

> **AI への注意:** テンプレートから作成した直後のプレースホルダ置換・メタ情報更新等の初期セットアップ手順は、プロジェクトの `AI_CONTEXT.md` に記載すること。このドキュメントはプロジェクト README の構成定義に専念する。

---

## 1. Required Sections (Follow Order)

1. **タイトル** — プロジェクト名
2. **言語宣言** — 正本・参照の宣言（[LANGUAGE_POLICY.md](../LANGUAGE_POLICY.md) `### When Using Separate Files` 参照）
3. **バッジ** — CI バッジ＋ ライセンスバッジ（§5 参照）
4. **一行概要** — 「何を・誰のために・どう解決するか」を 1 文で
5. **セットアップ** — ビルド・インストール手順（§2 参照）
6. **使い方** — 主なコマンド・操作フロー（§3 参照）
7. **ライセンス** — ライセンス名と `LICENSE` ファイルへのリンク

---

## 2. Setup Section

「動かせる状態」になるまでの最小手順を記載する。終点の定義は対象によって異なる。

| 対象 | セットアップの終点 |
|---|---|
| iOS / Mac アプリ | ビルド成功 → Simulator / 実機で起動 |
| Python app / library | `pip install -e .`（または `uv sync`）→ 動作確認コマンド実行 |
| Chrome 拡張 | `npm run build` → `chrome://extensions` でロード完了 |
| Alfred ワークフロー | `.alfredworkflow` をダブルクリック → Alfred に読み込み完了 |

**必須記載:**
- 依存関係のインストールコマンド
- ビルドコマンド（成果物がある場合）
- 初回設定（環境変数・設定ファイル等）

**記載しない:**
- テンプレート固有のカスタマイズ手順
- プレースホルダ置換手順（AI_CONTEXT.md に記載）

---

## 3. Usage Section

日常的な操作に必要なコマンド・フローを記載する。

- 管理コマンドが 3 つ以上ある場合はコマンド一覧を表形式で（`make` / `npm run` / `invoke` 等、ツールを問わない）
- 典型的なユースケース・操作フロー

---

## 4. Notes (Optional)

以下の場合のみ追加する。不要な場合はセクションごと省略する。

| 追加条件 | 内容 |
|---|---|
| 既知の制約・ハマりポイントがある | 具体的な回避策とともに記載 |
| プラットフォーム固有の注意点がある | 対象プラットフォームを明示して記載 |
| 破壊的操作がある | 警告と安全な代替手段を記載 |

---

## 5. Badge Format

バッジは**言語宣言の直後**（§1 位置 3）に配置する。

**CI バッジ:**

```
[![CI](https://github.com/{user}/{repo}/actions/workflows/{workflow}.yml/badge.svg)](https://github.com/{user}/{repo}/actions/workflows/{workflow}.yml)
```

⚠️ テンプレートから作成した場合、CI バッジの URL はテンプレートリポジトリを指したままになる。**このプロジェクト固有の `{user}` / `{repo}` / `{workflow}` に必ず更新すること。**

**ライセンスバッジ（プロジェクトの実際のライセンスに対応する行を使用）:**

| ライセンス | バッジ |
|---|---|
| MIT | `[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)` |
| All Rights Reserved | `[![License: All Rights Reserved](https://img.shields.io/badge/License-All%20Rights%20Reserved-red.svg)](LICENSE)` |
| CC BY-NC 4.0 | `[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](LICENSE)` |

ライセンスバッジのリンク先は常にリポジトリルートの `LICENSE` ファイル。テンプレートと異なるライセンスを選択した場合はバッジも変更すること。

---

## 6. Sections NOT Needed

プロジェクト README には不要（テンプレート固有）:

- テンプレートのメタ情報テーブル（詳細版）
- 「このテンプレートを使う」ボタン・クローン手順
- テンプレートのカスタマイズ手順
- 特徴セクションの `✅` リスト（プロジェクト固有の特徴に書き換えるか、一行概要に統合する）

---

## 7. Validation Checklist

README 作成・更新後に確認する。

```
[ ] 必須セクション（§1）が全て存在し、順序通りか
[ ] CI バッジの URL がこのプロジェクトリポジトリを指しているか（テンプレートの URL のままになっていないか）
[ ] ライセンスバッジがこのプロジェクトの実際のライセンスと一致しているか
[ ] 一行概要がテンプレートの説明ではなくプロジェクト固有の説明になっているか
[ ] セットアップ手順でプロジェクトが実際に動作するか
[ ] LICENSE ファイルの [YEAR] と [AUTHOR] が更新されているか
[ ] 日本語版・英語版が同一コミットで更新されているか
[ ] bilingual 文書の末尾に編集ルールフッターがあるか
```
