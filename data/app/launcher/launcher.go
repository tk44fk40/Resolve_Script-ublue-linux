package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// アプリケーション起動設定用 (data/app/<実行ファイル名>.json) の構造体
type Program struct {
	Program string `json:"program"` // 実行するプログラムのパス (例: bin\python-3.10.11\pythonw.exe)
	Arg     string `json:"arg"`     // 実行プログラムに渡す引数 (例: bin\launcher.py)
}

// 環境変数グループ (説明文 description と変数マップ vars) の構造体
type EnvGroup struct {
	Description string            `json:"description"`
	Vars        map[string]string `json:"vars"`
}

// 追加環境変数設定用 (data/app/env.json) の構造体 (Windows用に最適化)
type EnvConfig struct {
	Env struct {
		Common map[string]EnvGroup `json:"common"` // 全OS共通設定
		Win    map[string]EnvGroup `json:"win"`    // Windows専用設定
	} `json:"env"`
}

func run() int {
	// 1. 自身の実行ファイルの絶対パスを取得
	execPath, err := os.Executable()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Can't get the exec path")
		return 1
	}

	// 2. 作業ディレクトリを自身の実行ファイルが存在するディレクトリに変更
	execDir := filepath.Dir(execPath)
	if err := os.Chdir(execDir); err != nil {
		fmt.Fprintln(os.Stderr, "Can't get the exec path")
		return 1
	}

	// 3. 自身の実行ファイル名から拡張子を除いた幹名を取得 (例: "Resolve.exe" -> "Resolve")
	baseName := filepath.Base(execPath)
	execName := strings.TrimSuffix(baseName, filepath.Ext(baseName))
	if execName == "" {
		fmt.Fprintln(os.Stderr, "Can't get the exec name")
		return 1
	}

	// 4. 環境変数設定ファイル (data/app/env.json) が存在する場合はパースして自プロセスに反映
	envJsonPath := filepath.Join("data", "app", "env.json")
	if envData, err := os.ReadFile(envJsonPath); err == nil {
		var e EnvConfig
		if err := json.Unmarshal(envData, &e); err == nil {
			// Helper: グループ内の vars マップを環境変数展開 (os.ExpandEnv) の上、自プロセスに反映
			applyVars := func(groups map[string]EnvGroup) {
				for _, group := range groups {
					for k, v := range group.Vars {
						os.Setenv(k, os.ExpandEnv(v))
					}
				}
			}

			// ① 全OS共通設定 (env.common) の反映
			applyVars(e.Env.Common)

			// ② Windows専用設定 (env.win) の反映
			applyVars(e.Env.Win)
		}
	}

	// 5. 自身の名前と同名の設定ファイル (data/app/<実行ファイル名>.json) を読み込み
	progJsonPath := filepath.Join("data", "app", execName+".json")
	progData, err := os.ReadFile(progJsonPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to read config: %s\n", progJsonPath)
		return 1
	}

	var p Program
	if err := json.Unmarshal(progData, &p); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to parse config: %s\n", progJsonPath)
		return 1
	}

	// 6. 設定されたプログラムと引数を指定して非同期（バックグラウンド）で起動
	cmd := exec.Command(p.Program, p.Arg)

	// 現在の環境変数（env.json の設定を含む）をそのまま子プロセスへ引き継ぐ
	cmd.Env = os.Environ()

	if err := cmd.Start(); err != nil {
		fmt.Fprintln(os.Stderr, "Failed to execute command")
		return 1
	}

	return 0
}

func main() {
	os.Exit(run())
}
