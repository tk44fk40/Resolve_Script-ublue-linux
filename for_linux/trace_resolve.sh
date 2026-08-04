#!/usr/bin/bash
strace -f -e trace=execve -s 1000 /opt/resolve/bin/resolve 2>&1 | grep execve
