#!/bin/bash

# Resolve のアイコンをコピー
mkdir -p ${HOME}/.local/share/icons/hicolor/128x128/apps
ICON=/opt/resolve/graphics/DV_Resolve*.png
ICONS_PATH=${HOME}/.local/share/icons/hicolor/128x128/apps/
distrobox enter davincibox -- bash -c "cp ${ICON} ${ICONS_PATH}"

# 「りぞりぷと」の起動スクリプトを（~/.local/bin/ へ）登録
RESORIPT_SCRIPT="$(pwd)/りぞりぷと.sh"
distrobox enter davincibox -- distrobox-export --bin "$RESORIPT_SCRIPT"

# 「りぞりぷと」のランチャーを作成
cat << EOF > ~/.local/share/applications/りぞりぷと.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=りぞりぷと
GenericName=Resolve Script
Comment=Resolve_Script is an automation script tool designed to streamline workflows in DaVinci Resolve. 
Path=${HOME}
Exec=${HOME}/.local/bin/りぞりぷと.sh
Terminal=false
Icon=DV_ResolveBin
StartupWMClass=launcher.py
StartupNotify=true
Name[en_US]=Resolve Script
Categories=Utility;AudioVideo;AudioVideoEditing;Video;
EOF

# Resolve の起動スクリプトを（~/.local/bin/ へ）登録
RESOLVE_SCRIPT="$(pwd)/Resolve.sh"
distrobox enter davincibox -- distrobox-export --bin "$RESOLVE_SCRIPT"

# Resolve のランチャーを作成
cat << EOF > ~/.local/share/applications/resolve.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=DaVinci Resolve
GenericName=DaVinci Resolve
Comment=Revolutionary new tools for editing, visual effects, color correction and professional audio post production, all in a single application!
Path=${HOME}
Exec=${HOME}/.local/bin/Resolve.sh
Terminal=false
MimeType=application/x-resolveproj;
Icon=${HOME}/.local/share/icons/hicolor/128x128/apps/DV_Resolve.png
StartupNotify=true
Categories=AudioVideo;AudioVideoEditing;Video;
Name[en_US]=DaVinci Resolve
StartupWMClass=resolve
EOF

# Fusion のアイコンをコピー
# ICON=/opt/resolve/graphics/DV_Fusion*.png
# distrobox enter davincibox -- bash -c "cp ${ICON} ${ICONS_PATH}"

# Fusion の起動スクリプトを（~/.local/bin/ へ）登録
# FUSION_SCRIPT="$(pwd)/Resolve.sh"
# distrobox enter davincibox -- distrobox-export --bin "$FUSION_SCRIPT"Q
# Fusion のランチャーを作成
# cat << EOF > ~/.local/share/applications/fusion.desktop
# [Desktop Entry]
# Version=1.0
# Type=Application
# Name=Fusion Studio
# GenericName=Visual Effects & Motion Graphics
# Comment=Professional visual effects, 3D, VR and motion graphics solution
# Path=${HOME}
# Exec=${HOME}/.local/bin/Fusion.sh
# Terminal=false
# MimeType=application/x-fusioncomp;
# Icon=DV_Fusion
# StartupNotify=true
# Categories=AudioVideo;AudioVideoEditing;Video;Graphics;2DGraphics;3DGraphics;
# Name[en_US]=Fusion Studio
# StartupWMClass=fusion
# EOF

# アプリケーションランチャーを更新
gtk-update-icon-cache -f -t ${HOME}/.local/share/icons/hicolor/
update-desktop-database ${HOME}/.local/share/applications
