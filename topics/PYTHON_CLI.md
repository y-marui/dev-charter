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

## Key Points

- 設定ファイル形式は `.env` に統一する（global/local で同じ書き方）
- `env_file` は後ろに指定したファイルが優先される。存在しないファイルは無視される
- デフォルト値はフィールドに直接書く（TOML設定ファイルは不要）
