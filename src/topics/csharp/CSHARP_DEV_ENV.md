# C# Development Environment

Windows 向けデスクトップアプリ・ツール（.NET、WinForms 等）共通の開発環境構成を定義する。

このトピックは「.NET SDK を使う開発環境」の一般方針であり、アプリケーションの設計方針
（レイヤー構造・UI 設計・ドメインロジック）は対象外。それらは各プロジェクトが採用している
テンプレート／親リポジトリ側の `AI_CONTEXT.md` を正本とし、そちらを参照する
（[TEMPLATE_README_GUIDELINES.md（full）](https://github.com/y-marui/dev-charter/blob/full/topics/TEMPLATE_README_GUIDELINES.md)
「Relationship to dev-charter Dev-Env Topics」参照）。

## Version Policy

- **.NET SDK は LTS を使う。** メジャーバージョンは、CI の `actions/setup-dotnet` の
  `dotnet-version`（例: `8.0.x`）と各 csproj の `TargetFramework`（例: `net8.0-windows`）で揃える。
  `global.json` でパッチまで固定する仕組みは持たない（`x` 指定で、そのメジャーの最新パッチに追従する）
- メジャーバージョンの更新は、LTS の切り替わり（サポート終了の半年前を目安）に、
  `ci.yml`・csproj・README・`DEVELOPING.md` を同じ PR で更新して行う
- csproj の既定プロパティは次を標準とする:
  - `<Nullable>enable</Nullable>`
  - `<ImplicitUsings>enable</ImplicitUsings>`
  - `<InvariantGlobalization>true</InvariantGlobalization>`（アプリ内でカルチャ依存の動作が不要な場合）
- アセンブリのバージョンは csproj の `<Version>` を単一の情報源とし、`CHANGELOG.md` と揃える

## Toolchain

- ビルド・実行・テストは **`dotnet` CLI** で行う（Visual Studio を前提にしない）。
  ローカルの前提は .NET SDK だけで、`dotnet build` が入口になる
- Linter / Formatter: **`dotnet format`**（SDK 同梱）。CI は `--verify-no-changes` で実行し、
  差分があれば失敗させる。サードパーティの Analyzer は既定では追加しない
- フォーマット規則は、リポジトリ直下の `.editorconfig` で管理する（`dotnet format` が参照する）。
  規則を変える場合は、全ファイルに違反がないことを確認してからマージする

```powershell
dotnet format <Solution>.sln --verify-no-changes
```

- 複数プロジェクトの場合はソリューションを、単一プロジェクトの場合は csproj を対象にする

## Project Structure

- ソースは `src/<Project>/` に置く（プロジェクトごとに 1 ディレクトリ）。
  複数プロジェクトの場合は、ルートに `<Name>.sln` を置き、ライブラリ（`Core`）と
  実行ファイル（`Collector`・`Setup` 等）に分ける。単一プロジェクトでは `.sln` を省略してよい
- テストプロジェクトは `tests/<Project>.Tests/` に置く（[Testing](#testing) 参照）
- インストーラ（WiX）は `installer/` に置く
- `bin/`・`obj/`・`dist/` は `.gitignore` に入れる（ビルド成果物はコミットしない）
- 実行機固有の設定は `config.json` のように `.gitignore` 対象にし、`config.example.json` だけをコミットする

## Build and Publish

配布する実行ファイルは、**自己完結の単一ファイル**（win-x64）で作る。
利用者の PC に .NET ランタイムが無くても動く。csproj に次を書き、`dotnet publish` の
オプションを減らす:

```xml
<RuntimeIdentifier>win-x64</RuntimeIdentifier>
<SelfContained>true</SelfContained>
<PublishSingleFile>true</PublishSingleFile>
<IncludeNativeLibrariesForSelfExtract>true</IncludeNativeLibrariesForSelfExtract>
<EnableCompressionInSingleFile>true</EnableCompressionInSingleFile>
```

```powershell
dotnet publish src/<Project> -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o dist
```

- ビルドのコマンドは `Makefile`（または同等のスクリプト）に集約し、README・CI から同じコマンドを呼ぶ
- トレイアプリのように UI を持つ常駐アプリは、`OutputType` を `WinExe` にする（コンソールを出さない）。
  コンソールツールは `Exe`
- **Windows 専用のスタックである。** WinForms/WPF は `net8.0-windows` を対象にするため、
  Linux では `EnableWindowsTargeting` を指定しても `restore`/`build` までしか確かめられない
  （実行・テストは Windows が要る）。このため CI の `lint`・`build` は Windows ランナーで行う

### Installer (MSI)

MSI が要る場合は、WiX の SDK スタイル（`.wixproj`）を使い、`dotnet build` でビルドする。
`installer/` に置き、CI の `build` でも同じコマンドでビルドして壊れていないことを確認する。

```powershell
dotnet build installer/<Name>.Installer.wixproj -c Release -o dist
```

## Testing

- 認識・変換などのロジックは、ハードウェアや UI に依存しない**純粋な関数**として書き、
  実機なしで検証できるようにする
- テストプロジェクトを追加する場合は、`tests/<Project>.Tests/` に置き、`dotnet test` で実行する。
  フレームワークは xUnit を第一候補とする
- テストを追加したら、CI の `build` job で `dotnet test` を実行する（テストとビルドは同じ
  Windows job にまとめる。理由は [Runner Billing](https://github.com/y-marui/dev-charter/blob/full/topics/CI_POLICY.md#runner-billing) の「job の切り上げ」と同じ）
- UI・実機（カメラ等）のテストは自動化せず、手動で確認する。手順は `DEVELOPING.md` に残す

## Dependency Policy

- 既定でサードパーティの NuGet 依存ゼロ
- 追加してよい依存: Microsoft が提供する公式パッケージ（例: `System.ServiceProcess.ServiceController`）、
  テスト専用ライブラリ（テストプロジェクトにのみ追加）
- 上記以外の依存を追加する場合は、**ユーザーに確認し**、理由とライセンスを csproj のコメントと
  `AI_CONTEXT.md` に記録する。バージョンは `PackageReference` で固定する（浮動バージョンにしない）
- 追加の可否を判断するときは、まず .NET 標準ライブラリ・WinForms の範囲で実現できないかを検討する

## CI Integration

`CI_POLICY.md` の job 構成（`changes`・`security`・`lint`・`build`・`gate`）に従う。
C# では次の点が他のスタックと異なる:

- `security`・`changes`・`gate` は Linux、`lint`・`build` は **Windows** ランナーで動かす
  （上記のとおり Windows でしか確かめられないため）
- `lint` と `build` で `actions/setup-dotnet` を使う。`lint` は `dotnet format --verify-no-changes`、
  `build` は `dotnet publish`（MSI があれば `dotnet build` の wixproj も）を実行する
- `changes` job（`dorny/paths-filter`）は、PR の情報を読むため `permissions` に
  `contents: read` と `pull-requests: read` を付ける。付けないと private リポジトリで
  `Resource not accessible by integration` で失敗する
- 各 job に `timeout-minutes` を付ける（目安は `changes`・`gate` が 5、`security`・`lint` が 10、`build` が 30）
- ワークフローのトップレベルに `concurrency`（古い run のキャンセル）を付ける
- private リポジトリでは、リポジトリ変数 `LINUX_RUNNER`・`WINDOWS_RUNNER` で self-hosted
  runner に切り替えられる。**ランナーを登録してから、両方の変数を設定する**
  （条件は [Runner Billing](https://github.com/y-marui/dev-charter/blob/full/topics/CI_POLICY.md#runner-billing) 参照）

```yaml
lint:
  name: Lint
  needs: changes
  if: needs.changes.outputs.code == 'true'
  # WINDOWS_RUNNER は private リポジトリでのみ設定する。fork の PR は常に hosted
  runs-on: ${{ vars.WINDOWS_RUNNER && !github.event.pull_request.head.repo.fork && vars.WINDOWS_RUNNER || 'windows-latest' }}
  timeout-minutes: 10
  permissions:
    contents: read
  steps:
    - uses: actions/checkout@v7
    - uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'
    - run: dotnet format <Solution>.sln --verify-no-changes

build:
  name: Build
  needs: [changes, security, lint]
  if: needs.changes.outputs.code == 'true'
  runs-on: ${{ vars.WINDOWS_RUNNER && !github.event.pull_request.head.repo.fork && vars.WINDOWS_RUNNER || 'windows-latest' }}
  timeout-minutes: 30
  permissions:
    contents: read
  steps:
    - uses: actions/checkout@v7
    - uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'
    - run: dotnet publish src/<Project> -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o dist
```

`gate` の `needs` は `[changes, security, lint, build]` にし、結果の検証ループも `lint` と
`build` だけにする（`gate` の `name` はワークフロー自身の `name` と同じにする）。
