#!/bin/bash

# パッケージを更新
distrobox upgrade davincibox

# 必要なパッケージをインストール
distrobox enter davincibox -- sudo dnf install -y gcc gcc-c++ python3-devel alsa-lib-devel alsa-plugins-pulseaudio
distrobox enter davincibox -- sudo dnf install -y xset xrandr wmctrl xdotool fcitx5-qt5 jq

# brew をインストール
distrobox enter davincibox -- bash -c '
NONINTERACTIVE=1 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
command -v brew >/dev/null 2>&1 || echo '\''eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"'\'' >> $HOME/.bashrc
'

# uv をインストール
distrobox enter davincibox -- bash -c '
brew install -y -q uv
command -v uv >/dev/null 2>&1 || echo '\''eval "$(uv generate-shell-completion bash)"'\'' >> $HOME/.bashrc
'

# フォントをインストール
distrobox enter davincibox -- sudo dnf install -y google-noto-sans-jp-fonts google-noto-serif-jp-fonts
distrobox enter davincibox -- bash -c '
mkdir -p /tmp/textar_install
cd /tmp/textar_install
curl -L -o textar-font.zip "https://yamacraft.github.io/textar-font/textar-font.zip"
unzip -q textar-font.zip
sudo mkdir -p /usr/share/fonts/
sudo cp textar-font/textar.ttf /usr/share/fonts/
cd ~
rm -rf /tmp/textar_install
'

# ユーザーフォントディレクトリを認識させる
# Resolve が ~/.local/share/fonts も参照するようにしておく
distrobox enter davincibox -- bash -c '
sudo ln -sfn ~/.local/share/fonts /usr/share/fonts/user-fonts
sudo fc-cache -fv
fc-list : family | grep -i "Noto Sans JP"
fc-list : family | grep -i "Noto Serif CJK JP"
fc-list : family | grep -i "Textar"
'

# コンテナ内からホストのブラウザを開けるように細工する
distrobox enter davincibox -- bash patch-host-spawn.sh

# Qt5 用の Fcitx5 プラグインを Resolve のプラグインディレクトリにコピー
distrobox enter davincibox -- sudo mkdir -p /opt/resolve/libs/plugins/platforminputcontexts
distrobox enter davincibox -- bash -c '
SRC="/usr/lib64/qt5/plugins/platforminputcontexts/libfcitx5platforminputcontextplugin.so"
DST="/opt/resolve/libs/plugins/platforminputcontexts/"
sudo cp "$SRC" "$DST"
'
