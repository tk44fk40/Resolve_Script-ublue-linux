import json
import os
from pathlib import Path


def main():
    # スクリプトの親ディレクトリ (for_linux/ の親 = プロジェクトルート) を取得
    root_dir = Path(__file__).resolve().parent.parent
    env_file = root_dir.joinpath("data", "app", "env.json")

    if not env_file.exists():
        return

    with open(env_file, "r", encoding="utf-8") as f:
        data = json.load(f).get("env", {})

    def apply(block):
        for _, group in block.items():
            vars_map = group.get("vars", {})
            for k, v in vars_map.items():
                expanded_v = os.path.expandvars(v)
                os.environ[k] = expanded_v
                print(f'export {k}="{expanded_v}"')

    apply(data.get("common", {}))
    apply(data.get("linux", {}))


if __name__ == "__main__":
    main()
