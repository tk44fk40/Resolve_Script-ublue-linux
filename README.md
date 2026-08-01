# りぞりぷと (Linux/Bazzite 調整版)

「りぞりぷと」は、DaVinci Resolve での動画制作（立ち絵・字幕・音声作成など）を強力に支援する動画制作補助ツールです。

本プロジェクトは、「りぞりぷと」のリリース版をベースに、Linux / Bazzite (Universal Blue) 等の不変 OS 向けに、[davincibox][davincibox_link] コンテナ環境で利用するために調整・修正を加えたものです。

- **本家リポジトリ**: [nakano000/Resolve_Script (GitHub)](https://github.com/nakano000/Resolve_Script)

目次
- [りぞりぷと (Linux/Bazzite 調整版)](#りぞりぷと-linuxbazzite-調整版)
  - [主な修正内容](#主な修正内容)
  - [前提条件](#前提条件)
    - [必要な外部ツール](#必要な外部ツール)
    - [コンテナ内での実行を想定](#コンテナ内での実行を想定)
  - [コンテナのセットアップ](#コンテナのセットアップ)
  - [ランチャーの登録](#ランチャーの登録)
  - [使い方](#使い方)
    - [りぞりぷとの起動](#りぞりぷとの起動)
    - [DaVinci Resolve の起動](#davinci-resolve-の起動)

---

## 主な修正内容

Python (`uv` / `.venv`) や環境変数を最適化し、`wmctrl`/`xdotool` によるウィンドウ制御の安定化、日本語入力 (Fcitx5) 対応、日本語フォント（Noto / Textar）の自動インストール、ホストブラウザ連携、各種パス・依存関係の調整など、バグ修正や最適化を行っています。

---

## 前提条件

### 必要な外部ツール

- [distrobox](https://distrobox.it/) : ホストOSと統合した開発・デスクトップ利用向きコンテナ管理ツール
- [davincibox][davincibox_link] : DaVinci Resolve を Linux 環境で簡単に動かせるよう、Distrobox を利用して必要な依存関係や設定を自動化したプロジェクト
- [uv](https://github.com/astral-sh/uv) : Python のパッケージ・プロジェクト管理ツール

### コンテナ内での実行を想定

DaVinci Resolve を [davincibox][davincibox_link] コンテナにインストールし、「りぞりぷと」もコンテナ内で実行することを想定[^1]しています。

[^1]: 通常は、DaVinci Resolve 及び「りぞりぷと」は、ホスト OS にインストール・実行することが想定されていますが、本プロジェクトでは、ホスト OS の環境を（特に DaVinci Resolve のインストールによって）汚さないよう [davincibox][davincibox_link] コンテナ内にインストール・実行します。

---

## コンテナのセットアップ

1. [davincibox][davincibox_link] をセットアップします。

   例： `~/tmp/resolve` にセットアップ用スクリプトと DaVinci Resolve （バージョン 21.0.3[^2]）のインストーラーをダウンロードしてセットアップする例

   [^2]: バージョン番号は適宜、最新バージョンに読み替えてください。

   - DaVinci Resolve のインストーラーをダウンロードします。
     公式サイトから Linux 用の zip ファイルをダウンロードして `~/tmp/resolve`  に配置し、解凍します。

      ```bash
      # 作業用ディレクトリを作ります
      mkdir -p ~/tmp/resolve
      # 作業用ディレクトリに、ダウンロードした zip ファイルを置いてください
      # 作業用ディレクトリでインストーラー(*.run)を解凍します
      cd ~/tmp/resolve
      unzip DaVinci_Resolve_21.0.3_Linux.zip "*.run"
      ```

   - [davincibox][davincibox_link] の GitHub リポジトリからセットアップスクリプトをダウンロードします。

      ```bash
      cd ~/tmp/resolve
      curl -O https://raw.githubusercontent.com/zelikos/davincibox/master/setup.sh
      ```

   - スクリプトを実行してコンテナを作ります。

      ```bash
      cd ~/tmp/resolve
      bash setup.sh DaVinci_Resolve_21.0.3_Linux.run distrobox
      ```

      以下のような表示になれば、インストール成功です。

      ```
      DaVinci Resolve installed to /opt/resolve

      Done
      Patching resolve binaries...
      patchelf: not an ELF executable
      patchelf: not an ELF executable
      patchelf: not an ELF executable
      Applying workaround for companion programs...
      Add DaVinci Resolve launcher? Y/n
      ```

      起動用の `.desktop` ファイルを作りますか？
      `Add DaVinci Resolve launcher? Y/n`
      と聞かれますが、ここでは `n` でスキップしておいてください。
      「りぞりぷと」では、**直接 DaVinci Resolve を起動すると正しく動作しません。必ずスクリプト経由で起動してください。**
      別途、起動用のランチャー（`.desktop` ファイル）を作成します。

   - 不要になった作業ディレクトリは削除してしまっても構いません。

      ```bash
      cd ~/tmp/resolve
      rm *
      cd ~/
      rmdir ~/tmp/resolve
      ```

2. 以下のスクリプトを実行し、[davincibox][davincibox_link] コンテナに必要なパッケージ類（日本語入力 Fcitx5 プラグイン、日本語フォント、ホストブラウザ連携含む）をセットアップします。
   ```bash
   ./setup_davincibox.sh
   ```

3. 以下のスクリプトを実行し、コンテナ内に Python 仮想環境（`.venv`）を作成し、依存パッケージをインストールします。

  ```bash
  distrobox enter davincibox -- ./setup_python.sh
  ```

---

## ランチャーの登録

「りぞりぷと」及び DaVinci Resolve は、コンテナ内で起動する必要があります。

このままでは起動するのが煩雑なので、起動スクリプトを `~/.local/bin/` に登録してホストから簡単に起動できるようにします。
また、ランチャーファイル（`.desktop` ファイル）を作成して、ホストのアプリケーションランチャーから起動できるようにします。

```bash
./setup_launcher.sh
```

---

## 使い方

### りぞりぷとの起動[^3]

```bash
~/.local/bin/resoript.sh
# ~/.local/bin が PATH に登録されていれば以下でも起動します
resoript.sh
```

アプリケーションランチャーの `りぞりぷと` からも起動できます。

[^3]: `resoript.sh` は `りぞりぷと.sh` の別名コピーです。どちらを実行しても同じように起動します。

### DaVinci Resolve の起動

```bash
~/.local/bin/Resolve.sh
# ~/.local/bin が PATH に登録されていれば以下でも起動します
Resolve.sh
```

アプリケーションランチャーの `DaVinci Rersolve` からも起動できます。

[davincibox_link]: https://github.com/zelikos/davincibox
