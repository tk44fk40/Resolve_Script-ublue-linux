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

# Pythonバージョンを指定してプロジェクトを初期化
uv python install 3.10.11
uv init -p 3.10.11

# 仮想環境を作成
uv venv -p 3.10.11 --clear
uv python pin 3.10.11

# 依存パッケージをインストール
# 予め requirements.txt を以下の通り修正しておきます
# - pywin32
#   Windows用パッケージ pywin32 は Linux 環境で無効
#   修正前: pywin32==306
#   修正後: pywin32==306; sys_platform == "win32"
# - pyworld
#   pyworld パッケージが、古いバージョンの setuptools が提供する
#   pkg_resources モジュールに依存しているため、setuptools の
#   バージョンを下げる
#   修正前: setuptools なし
#   修正後: setuptools<70
sed -i 's/^pywin32==306$/pywin32==306; sys_platform == "win32"/' requirements.txt
if grep -q "^setuptools$" requirements.txt; then
    sed -i 's/^setuptools$/setuptools<70/' requirements.txt
else
    echo "setuptools<70" >> requirements.txt
fi
uv add -r requirements.txt
