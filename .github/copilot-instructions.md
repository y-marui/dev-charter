# GitHub Copilot Instructions

<!-- このファイルは AI_CONTEXT.md の内容を Copilot 用にミラーしています。 -->
<!-- AI_CONTEXT.md を更新した場合はこのファイルも同一コミットで更新してください。 -->

このリポジトリは dev-charter の本体。他プロジェクトが `git subtree` で取り込む共有開発憲章。
ドキュメントのみのリポジトリ（ソースコードなし）。

## メンテナンスルール

- **正本は日本語**。英語版（README.md）は翻訳。日本語版と英語版は同一コミットで更新する
- **Conventional Commits**（feat/fix/docs/chore）でコミットする
- **新規ドキュメントを追加するとき**は両言語の README のドキュメント一覧テーブルも更新する
- **憲章に追加できる原則・ルール**は複数の異なるプロジェクトに適用できるものに限る（1プロジェクト固有のルールは不可）

## セキュリティフック

- `core.hooksPath` **設定済み**：`pre-commit install` 不要。`pre-commit run --all-files` で動作確認
- `core.hooksPath` **未設定**：`pre-commit install` 後に `pre-commit run --all-files` で動作確認

## 禁止事項

- シークレット・認証情報のコミット
- 未完成・曖昧な原則のコミット（issue で管理する）
- プロジェクト固有のルールを憲章に追加すること
- ソースコード・ビルド成果物・ログのコミット
