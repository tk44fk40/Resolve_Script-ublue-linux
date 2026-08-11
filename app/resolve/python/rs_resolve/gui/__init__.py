import subprocess

from rs.core import util


class LinuxWindow:
    def activate(self) -> bool:
        return _activate_linux_fallback()


def _get_linux_resolve_window(pj_name: str):
    # 1. wmctrl -l
    try:
        res = subprocess.run(['wmctrl', '-l'], capture_output=True, encoding='utf-8', errors='ignore')
        if res.returncode == 0:
            for line in res.stdout.splitlines():
                parts = line.split(maxsplit=3)
                if len(parts) >= 4:
                    title = parts[3]
                    if 'DaVinci Resolve' in title:
                        if pj_name == '' or title.endswith(pj_name) or pj_name in title or 'by Blackmagic Design' in title:
                            return LinuxWindow()
    except Exception as e:
        print(f"wmctrl error: {e}")

    # 2. xdotool search
    try:
        res2 = subprocess.run(['xdotool', 'search', '--onlyvisible', '--name', 'DaVinci Resolve'], capture_output=True, encoding='utf-8', errors='ignore')
        if res2.returncode == 0 and res2.stdout.strip() != '':
            return LinuxWindow()
    except Exception as e:
        print(f"xdotool error: {e}")

    print("wmctrl / xdotool could not detect DaVinci Resolve window.")
    return None


if util.IS_WIN:
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

elif not util.IS_MAC:
    def get_resolve_window(pj_name):
        return _get_linux_resolve_window(pj_name)

else:
    def get_resolve_window(pj_name):
        return None


def _activate_linux_fallback():
    try:
        res = subprocess.run(['wmctrl', '-a', 'DaVinci Resolve'], capture_output=True, encoding='utf-8', errors='ignore')
        if res.returncode == 0:
            return True
        res2 = subprocess.run(['xdotool', 'search', '--onlyvisible', '--name', 'DaVinci Resolve', 'windowactivate'], capture_output=True, encoding='utf-8', errors='ignore')
        return res2.returncode == 0
    except Exception as e:
        print(f'fallback activation failed: {e}')
        return False


def activate_window(w) -> bool:
    if not util.IS_MAC and not util.IS_WIN:
        if w is not None:
            return w.activate()
        return False
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

