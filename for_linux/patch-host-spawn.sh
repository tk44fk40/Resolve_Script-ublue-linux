#!/bin/bash

if [ "$CONTAINER_ID" != "davincibox" ] || ! grep -q "name=.*davincibox" /run/.containerenv 2>/dev/null; then
    echo "Error: This script must be run inside the 'davincibox' Distrobox container."
    exit 1
fi

#【注意】
# このスクリプトは**必ず** davincibox コンテナ内で実行してください。
# コンテナ内でのみ実行されるようにガードを入れてありますが、万一ホスト側で実行されると
# xdg-open, evince が機能しなくなります。

# 1. URL などを開く xdg-open はホスト側に投げる
for path in /usr/bin/xdg-open /usr/local/bin/xdg-open; do
    if [ -e "$path" ] && [ ! -L "$path" ] && [ ! -e "${path}.real" ]; then
        sudo mv "$path" "${path}.real"
    fi
    sudo rm -f "$path"
    sudo tee "$path" << 'EOF' > /dev/null
#!/bin/bash
exec /usr/bin/host-spawn xdg-open "$@"
EOF
    sudo chmod +x "$path"
done

# 2. evince はコンテナ内に実体がない/動かないため、ファイルをホストに見える場所へコピーしてホストの xdg-open で開く
EVINCE_PATH="/usr/bin/evince"
if [ ! -e "$EVINCE_PATH" ] || [ -L "$EVINCE_PATH" ] || [ -e "${EVINCE_PATH}.real" ]; then
    sudo rm -f "$EVINCE_PATH"
    sudo tee "$EVINCE_PATH" << 'EOF' > /dev/null
#!/bin/bash
for arg in "$@"; do
    # 引数が実在するファイルなら
    if [[ -f "$arg" ]]; then
        # ホストからも確実に見える ~/.cache に一時コピー
        TMP_FILE="$HOME/.cache/$(basename "$arg")"
        cp -f "$arg" "$TMP_FILE"
        
        # 生成済みの host-spawn ラッパーに投げる（unset等もあちらで処理される）
        exec /usr/bin/host-spawn xdg-open "$TMP_FILE"
    fi
done
EOF
    sudo chmod +x "$EVINCE_PATH"
fi

# 3. 本物の host-spawn を .real として退避
if [ ! -f /usr/bin/host-spawn.real ]; then
    sudo mv /usr/bin/host-spawn /usr/bin/host-spawn.real
fi

# 4. host-spawn のラッパー (PWD問題の対策入り)
sudo tee /usr/bin/host-spawn << 'EOF' > /dev/null
#!/bin/bash
unset LD_LIBRARY_PATH
unset LD_PRELOAD
unset PYTHONHOME
unset PYTHONPATH
unset QT_QPA_PLATFORM
unset QT_PLUGIN_PATH
cd "$HOME" || cd /
exec -a "$0" /usr/bin/host-spawn.real "$@"
EOF
sudo chmod +x /usr/bin/host-spawn

# 呼び出された際の環境変数と引数をログに出力する場合はこんな感じ
# echo "Arguments: $@" >> ~/host-spawn-resolve.log
# env >> ~/host-spawn-resolve.log
# exec -a "$0" /usr/bin/host-spawn.real "$@" >> ~/host-spawn-resolve.log 2>&1
