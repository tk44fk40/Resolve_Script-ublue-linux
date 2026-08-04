#!/bin/bash

# 使用方法: ./build.sh [ソースファイルパス] [出力先ディレクトリ]
# 例: ./build.sh launcher.go /tmp/dist  -> /tmp/dist/launcher.exe が 1 つだけ生成される
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 第1引数: ソースファイル (デフォルト: 同一ディレクトリの launcher.go)
SOURCE_FILE="${1:-$SCRIPT_DIR/launcher.go}"

# 第2引数: 出力先ディレクトリ (デフォルト: 同一ディレクトリの build/)
OUT_DIR="${2:-$SCRIPT_DIR/build}"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file '$SOURCE_FILE' not found." >&2
    exit 1
fi

# ソースファイルの拡張子を除いた幹名を取得 (例: "launcher.go" -> "launcher")
SRC_BASE=$(basename "$SOURCE_FILE")
SRC_STEM="${SRC_BASE%.*}"

mkdir -p "$OUT_DIR"
OUT_EXE="$OUT_DIR/${SRC_STEM}.exe"

echo "=== Building Windows Launcher ==="
echo "Source: $SOURCE_FILE"
echo "Output: $OUT_EXE"

# クロスコンパイル実行 (-ldflags "-H windowsgui -s -w" でコンソール非表示)
GOOS=windows GOARCH=amd64 go build -ldflags "-H windowsgui -s -w" -o "$OUT_EXE" "$SOURCE_FILE"

echo "Build complete! Generated: $OUT_EXE"
ls -lh "$OUT_EXE"
