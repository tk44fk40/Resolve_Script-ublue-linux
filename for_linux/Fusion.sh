#!/bin/bash

cd "$(dirname "$0")"

source "./env.sh"

uv run bin/run_fusion.py

# Fusion が終了するまで待機
# （ホストOSのアプリケーションランチャーから .desktop ファイル経由で起動する場合に即死しないように）
sleep 3
while pgrep -f "/Fusion$" >/dev/null 2>&1; do
    sleep 1
done
