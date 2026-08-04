import os
import sys

base_dir = os.path.dirname(__file__)

# 1. Lib/site-packages (PySide6等のサードパーティライブラリ) を自動追加
site_packages = os.path.join(base_dir, 'Lib', 'site-packages')
if os.path.exists(site_packages) and site_packages not in sys.path:
    sys.path.insert(0, site_packages)

# 2. resolve.py / fusion.py がセットした環境変数 PYTHONPATH (rs_fusion等) を動的追加
pythonpath = os.environ.get('PYTHONPATH')
if pythonpath:
    for path in pythonpath.split(os.pathsep):
        if path and path not in sys.path:
            sys.path.insert(0, path)
