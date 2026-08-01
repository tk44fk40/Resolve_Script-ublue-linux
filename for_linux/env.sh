#!/bin/bash

# PATH を通す
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="${HOME}/.local/bin:${PATH}"
export PATH=$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')

export QT_QPA_PLATFORM=xcb  # X11（xcb）互換モード
export QT_AUTO_SCREEN_SCALE_FACTOR=1  # UI の拡大率を自動調整

# ResolveのPathmapと連動し、
# りぞりぷと専用のスクリプト群を読み込ませるパス
export RS_FUSION_USER_PATH="$(pwd)/app/fusion/UserPath"

# DaVinci Resolve が使用する Python3 ライブラリの検索パス
# Resolve は Pyhton の実行バイナリではなくライブラリを使うので、
# PATHではなく LD_LIBRARY_PATH で指定する
export PYTHONHOME="${HOME}/.local/share/uv/python/cpython-3.10.11-linux-x86_64-gnu"
export LD_LIBRARY_PATH="${PYTHONHOME}/lib:${LD_LIBRARY_PATH}"
