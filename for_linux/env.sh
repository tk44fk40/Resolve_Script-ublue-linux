#!/bin/bash

# PATH の設定
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null)" || true
export PATH="${HOME}/.local/bin:${PATH}"
export PATH=$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')

# スクリプトの配置ディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# env.json から common と linux の環境変数を抽出して export
ENV_JSON="$SCRIPT_DIR/data/app/env.json"
if [ -f "$ENV_JSON" ] && command -v jq >/dev/null 2>&1; then
    eval "$(jq -r '(.env.common // {}), (.env.linux // {}) | .[]? | .vars? // {} | to_entries[] | "export \(.key)=\"\(.value)\""' "$ENV_JSON")"
fi
