# Resolve_Script-ublue-linux 開発・動作ルール

## プロジェクト固有ルール
- **OS 別リリースパッケージ構造 (GitHub Actions CI)**:
  - Linux 版 / Mac 版のリリース ZIP パッケージ構築時、`for_linux/` または `for_mac/` ディレクトリの中身がパッケージ直下（ルート）に展開・上書きされた構成でビルドされる。
  - Windows 版のリリース ZIP パッケージには、`bin/python-3.10.11`（Embeddable Python）が同梱される。
- **Windows 版 Embeddable Python と sitecustomize.py**:
  - Windows 版同梱の Embeddable Python は仕様上 `PYTHONPATH` 環境変数を無視するため、パス拡張は `data/app/launcher/sitecustomize.py` を経由して `sys.path` へ動的注入する仕組みになっている。
- **Linux 動作環境 (davincibox) と起動経路の注意**:
  - DaVinci Resolve および「りぞりぷと」は `davincibox` コンテナ内での動作前提。
  - コンテナ自動生成のデスクトップアイコン等から起動すると環境変数が適用されないため、必ず起動スクリプト (`Resolve.sh` / `りぞりぷと.sh`) または `./setup_launcher.sh` 経由のランチャーから起動すること。
- **配置パスにおける日本語（全角文字）の禁止**:
  - 配置先パスに日本語（全角文字・スペース）が含まれると Python モジュールインポート (`rs_fusion` 等) が失敗するため、必ず半角英数字のパス（例: `~/scripts/...`）に配置すること。
- **env.json と Python 側環境変数の重複回避**:
  - `RS_FUSION_USER_PATH` のように Python 側 (`fusion.py`) で自動計算される環境変数は、`data/app/env.json` に重複記述しないこと。
