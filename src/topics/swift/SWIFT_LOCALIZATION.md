# Swift Localization

Swift / SwiftUI アプリで、アプリ内の言語設定を実装するときの標準を定義する。

対応言語・ロケール識別子・言語決定の優先順位は言語に依存しない方針として
[LOCALIZATION_POLICY.md](../../LOCALIZATION_POLICY.md) が定める。このトピックは、その方針を
Swift / SwiftUI で実装する形（型・保存・反映・設定画面・文言の書き方）を扱う。

この標準は、テンプレートへの実装と、複数の Swift アプリへの展開を経た形である。
Clean Architecture のレイヤー構造などアプリケーション設計方針は対象外
（[SWIFT_DEV_ENV.md](SWIFT_DEV_ENV.md) と同様、各プロジェクトの `AI_CONTEXT.md` を正本とする）。

## AppLanguage

アプリ内で選べる言語を、次の型で表す。`Packages/Core` の Domain に置き、Foundation のみに依存させる。

~~~swift
public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system
    case ja, en
    case zhHans = "zh-Hans"
    case hi, es, fr, pt
}
~~~

- `rawValue` を保存値かつロケール識別子にする（`system` は `"system"`）
- 保存値の復元は `init(storedValue:)` で行い、不明な値は `system` として扱う
- 表示名は `nativeName` として各言語の自国語表記で固定する。`system` だけがローカライズ対象のため `nil` を返し、
  呼び出し側が `settings.language.system` をローカライズして表示する
- 保存キーは `appLanguage` とする（`storageKey` として型に持たせてよい）

### resolvedLocale

`resolvedLocale: Locale` は、[Language Resolution](../../LOCALIZATION_POLICY.md#language-resolution) の優先順位を実装する。

1. 明示の言語（`system` 以外）なら、その言語の `Locale(identifier: rawValue)`
2. `system` なら、`Locale.preferredLanguages` から、対応言語に一致する最初のもの
3. 一致がなければ英語

一致判定は言語コードで行う。中国語（`zh`）だけは文字体系まで見て、簡体字（`Hans`）のときに限り `zh-Hans` とする。
文字体系がない `zh-TW`・`zh-HK`・`zh-MO` は繁体字として対応外にし、英語にフォールバックする。
`preferredLanguages` を引数に取るオーバーロードを用意すると、テストで差し替えられる。

## Storage

保存先は App Group の `UserDefaults(suiteName:)` の `appLanguage` キーを標準とする。
Widget・Intents・Keyboard の Extension が同じ値を読めるためである。SwiftUI からは
`@AppStorage(AppLanguage.storageKey, store: ...)` で読み書きする。

保存先の例外は、アプリ側の制約があるときだけ許す。

- Widget のサンドボックス制約などで `UserDefaults` を共有できないアプリは、既存の共有手段（設定ファイル、
  共有ストア等）に保存してよい。その場合も保存値は `rawValue` とし、旧形式や未知の値は `system` として読む
- 既存アプリの保存値を変える場合は、旧値を 1 回だけ読み替える移行を入れる（移行先に値があれば上書きしない）

## Applying the Language

反映は 2 層に分ける。

### SwiftUI

全シーンのルート（ウィンドウ・`Settings`・メニューバー・独立パネル・シート）に
`.environment(\.locale, language.resolvedLocale)` を付ける。即時に反映される。
シーンを 1 つでも漏らすと、そのシーンだけシステム言語のままになる。

### Extension

Extension は App Group から `appLanguage` を読む。Widget は次の形にする。

- Provider が読み、タイムラインの entry（またはスナップショット）に含める
- View が `.environment(\.locale, ...)` を付ける
- アプリ側で言語を変えたら、Widget のタイムラインを再読込する

Keyboard Extension は、`UIHostingController` などのルートに同じ `.environment(\.locale, ...)` を付ける。

### Non-SwiftUI strings

`String(localized:)`・App Intents・AppleScript の文言は、環境の `locale` では変わらない。
これらが必要なアプリだけ、次のどちらかを使う。

- **選択言語の lproj を直接引く。** ビュー外の文言（パネルのタイトル、エラー文言など）に向く。
  解決した識別子の `.lproj` の `Bundle` から `localizedString(forKey:value:table:)` で引き、見つからなければ
  既定の `Bundle` に戻す。即時に反映される。システムが返す文言（OS のエラー本文など）は対象外
- **起動時に `AppleLanguages` へ書き込む。** App Intents・AppleScript など、環境の `locale` も lproj の直接参照も
  届かない箇所に使う。`UserDefaults.standard` の `AppleLanguages` へ選択言語を書き込み、反映はアプリの
  再起動後になる。使うアプリは、設定画面に「再起動後に反映される」旨を出す

どちらも、必要になったアプリだけが実装する（YAGNI）。テンプレートには含めない。

## Settings Screen

設定画面に「言語」セクションを置き、`AppLanguage.allCases` の `Picker` にする。

- 各項目の表示名は `nativeName`。`system` だけローカライズした文言を出す
- macOS は `Settings` シーン、iOS は設定タブなど、プラットフォームの導線に合わせる

## Strings in Code

SwiftUI のビューでは、環境の `locale` を参照する書き方を使う。`String(localized:)` は環境の `locale` を無視するため、
ビューの文言に使うとアプリ内の言語設定が反映されない。

~~~swift
// 推奨: 環境の locale に従う
Text("feature.title", bundle: .module)

// 避ける: 環境の locale を無視する
Text(String(localized: "feature.title"))

// 禁止: ハードコードされた文字列
Text("タイトル")
~~~

- Swift Package（`Packages/Core` 等）内のビューは `bundle: .module` を指定する
- `LocalizedStringKey` を引数に取る API（`Text`・`Label`・`Button` 等）にはキーをそのまま渡す
- 計算結果の文言（残り時間など）やビュー外の文言は環境の `locale` を購読しない。選択言語を明示的に解決して渡す
  （[Non-SwiftUI strings](#non-swiftui-strings) 参照）

### Rebuilding on Language Change

言語の変更時に、ビューツリーの一部が古い言語のまま残ることがある（`Picker` の単位、アラート、タブ名など）。
その場合はルートに `.id(language)` を付けて作り直す。開いている画面の一時的な状態は戻るため、
必要になったアプリだけが採用する。

## String Catalog

- 文言は Xcode の String Catalog（`Localizable.xcstrings`）で管理する。Swift Package のリソースとして
  `Packages/Core/Sources/Core/Resources/` に置く
- `Package.swift` に `defaultLocalization` と `resources: [.process("Resources")]` を指定する
- カタログは対応言語の 7 言語すべてで揃える。ポルトガル語の言語キーは `pt`（`pt-BR` などの地域付きにしない）
- アプリが対応言語の一部しか翻訳していない場合は、翻訳を追加するか、選択肢を実際の対応言語に絞るかを決める。
  選べるのに翻訳がない言語を残さない

### Key Naming Convention

文言のキーは `<スコープ>.<内容>` のドット区切りにする。文言そのものをキーにしない。

~~~text
common.retry        → 再試行
common.error.title  → エラー
settings.language.title   → 言語
settings.language.system  → システム設定
~~~

文言を変えてもキーが変わらず、翻訳の対応づけが壊れない。スコープは機能名・画面名・共通（`common`）などで切る。

## Testing

`AppLanguage` は Foundation のみに依存するため、ユニットテストで次を確認する。

- 明示の言語は、その言語の `Locale` になる
- `system` は、`preferredLanguages` の最初の対応言語に解決される
- 対応外の言語、繁体字（`zh-Hant`・`zh-TW` 等）は英語になる
- 不明な保存値は `system` になる

カタログの文言をテストで確認する場合、`String(localized:)` は使わず、ソースの `Localizable.xcstrings` を直接
パースする。Xcode 26.x の SwiftPM は `.xcstrings` を `.lproj` にコンパイルしないため、`String(localized:)` を使う
テストは `swift test` で失敗することがある。

## Verification

次はユニットテストで確認できないため、実機（または実行環境）で確認する。

- `Picker` を切り替えると、すべてのシーンの表示が即時に変わる
- Widget・Keyboard などの Extension が、アプリの言語に追従する
- `AppleLanguages` 方式を使うアプリは、再起動後に反映される
