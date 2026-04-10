# Python CLI

PythonでCLIを実装する場合の標準構成を定義する。

## Library Stack

| 役割 | ライブラリ |
|---|---|
| CLI引数 | `typer` |
| 設定管理 | `pydantic-settings` |

## Configuration Priority

```
CLI引数 > 環境変数・.env > グローバル設定ファイル > デフォルト値
```

## Config File Location

```
$XDG_CONFIG_HOME/appname   # グローバル設定（fallback）
.env                        # プロジェクトローカル（優先）
```

`XDG_CONFIG_HOME` 未設定時は `~/.config` にフォールバック。XDG Base Directory 仕様に従い、他ツールと一貫性を保つ。

## Settings Skeleton

```python
import os
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict

XDG_CONFIG_HOME = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
CONFIG_FILE = XDG_CONFIG_HOME / "appname"

class Settings(BaseSettings):
    api_key: str = ""
    debug: bool = False
    timeout: int = 30

    model_config = SettingsConfigDict(
        env_file=[CONFIG_FILE, ".env"],
        env_prefix="APP_",
    )
```

## Missing Config Handling

設定ファイルが存在しない場合は、単純にエラー終了せず作成を促す。

### For development (リポジトリ内で使う場合)

README に以下を記載し、手動コピーを案内する：

```markdown
## Setup

cp .env.example .env
# .env を編集して必要な値を設定してください
```

### For installed package (pip/uv install した場合)

初回起動時にグローバル設定の不在を検出し、`.env.example` をコピーするか対話的に確認する：

```python
import shutil
import typer

EXAMPLE_FILE = Path(__file__).parent / ".env.example"

def ensure_config() -> None:
    """設定ファイルが存在しない場合、作成を促す。"""
    if CONFIG_FILE.exists() or Path(".env").exists():
        return

    typer.echo(f"設定ファイルが見つかりません: {CONFIG_FILE}", err=True)

    if EXAMPLE_FILE.exists() and typer.confirm(
        f".env.example を {CONFIG_FILE} にコピーしますか？"
    ):
        CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(EXAMPLE_FILE, CONFIG_FILE)
        typer.echo(f"コピーしました: {CONFIG_FILE}")
        typer.echo("必要な値を設定してから再度実行してください。")
    else:
        typer.echo(f"次のファイルを作成して設定してください: {CONFIG_FILE}", err=True)

    raise typer.Exit(1)
```

エントリポイントで各コマンドの前に呼び出す：

```python
app = typer.Typer()

@app.callback()
def main() -> None:
    ensure_config()
```

## Key Points

- 設定ファイル形式は `.env` に統一する（global/local で同じ書き方）
- `env_file` は後ろに指定したファイルが優先される。存在しないファイルは無視される
- デフォルト値はフィールドに直接書く（TOML設定ファイルは不要）
- `.env.example` はリポジトリに含め、実際の `.env` は `.gitignore` に追加する
