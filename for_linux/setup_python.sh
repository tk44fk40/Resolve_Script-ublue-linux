#!/bin/bash

cd "$(dirname "$0")"

# Python のバージョンについて
# Resolve が安定して動作する Python のバージョン
#  Python 3.10
# りぞりぷと Windows 版が同梱する Python のバージョン
#  Python 3.10.11
# davincibox(Fedora 44) のデフォルトの Python バージョン
#  Python 3.14
# ※Python 3.12 以降で完全に削除されたモジュール
#   （imp や distutils など）に依存しているため 3.14 は不可

# Linux 環境で不要な Windows 専用パッケージ pywin32 にプラットフォーム条件を付与
sed -i 's/^pywin32==306$/pywin32==306; sys_platform == "win32"/' requirements.txt

# pyworld 等が依存する pkg_resources の互換性のため setuptools を 70 未満に制限
if grep -q "^setuptools$" requirements.txt; then
    sed -i 's/^setuptools$/setuptools<70/' requirements.txt
elif ! grep -q "setuptools" requirements.txt; then
    echo "setuptools<70" >> requirements.txt
fi

# 既存の uv / Python 関連設定ファイルを削除して毎回クリーンな状態にする
rm -f pyproject.toml .python-version uv.lock
rm -rf .venv

# davincibox コンテナ内で Python 仮想環境および依存パッケージをセットアップ
distrobox enter davincibox -- bash -c '
# Homebrew のパスを通す
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)" 2>/dev/null || true

# Pythonバージョンを指定してプロジェクトを初期化
uv python install 3.10.11
uv init -p 3.10.11

# 仮想環境を作成
uv venv -p 3.10.11 --clear
uv python pin 3.10.11

# 依存パッケージをインストール
uv add -r requirements.txt
'
