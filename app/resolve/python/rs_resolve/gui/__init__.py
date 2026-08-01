import subprocess

from rs.core import util

if util.IS_MAC:
    def get_resolve_window(pj_name):
        return None
else:
    import pywinctl


    def get_resolve_window(pj_name):
        try:
            for t in pywinctl.getAllTitles():
                flag = t.startswith('DaVinci Resolve') and t.endswith(pj_name)
                flag = flag or t.startswith('DaVinci Resolve by Blackmagic Design')
                if flag:
                    return pywinctl.getWindowsWithTitle(t)[0]
        except Exception as e:
            print(f"pywinctl error: {e}")
        return None

def _activate_linux_fallback():
    try:
        res = subprocess.run(['wmctrl', '-a', 'DaVinci Resolve'], capture_output=True, text=True)
        if res.returncode == 0:
            return True
        res2 = subprocess.run(['xdotool', 'search', '--onlyvisible', '--name', 'DaVinci Resolve', 'windowactivate'], capture_output=True, text=True)
        return res2.returncode == 0
    except Exception as e:
        print(f'fallback activation failed: {e}')
        return False

def activate_window(w) -> bool:
    if not util.IS_MAC and not util.IS_WIN:
        try:
            if w is not None:
                w.activate()
                return True
        except Exception as e:
            print(f'pywinctl activate error: {e}')
        return _activate_linux_fallback()
    elif not util.IS_MAC:
        if w is not None:
            w.activate()
            return True
    else:
        subprocess.run([
            'osascript',
            '-e',
            'tell application "DaVinci Resolve" to activate',
        ])
        return True
    return False
