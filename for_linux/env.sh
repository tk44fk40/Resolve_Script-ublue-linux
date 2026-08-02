#!/bin/bash

# PATH の設定
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null)" || true
export PATH="${HOME}/.local/bin:${PATH}"
export PATH=$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')

# load_env.py を呼び出して data/app/env.json の環境変数をロード・適用
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/load_env.py" ]; then
    eval "$(python3 "$SCRIPT_DIR/load_env.py")"
fi
