#!/usr/bin/env python

# Modified version of https://github.com/akkana/scripts/blob/master/termsize

import os
import sys
import fcntl
import re
import select
import struct
import termios
import tty


# Save the terminal state
fileno = sys.stdin.fileno()
stty_old = termios.tcgetattr(sys.stdin)
fc_old = fcntl.fcntl(fileno, fcntl.F_GETFL)

# Turn off echo
stty_new = stty_old[:]
stty_new[3] = stty_new[3] & ~termios.ECHO

if sys.version_info < (3, 0):
    ttyfd = open('/dev/tty', 'r+')
    termios.tcsetattr(ttyfd, termios.TCSANOW, stty_new)
else:
    # Python 3 needs extra flags set, which requires a 2-step open process:
    fd = os.open('/dev/tty', os.O_RDWR | os.O_NOCTTY)
    ttyfd = open(fd, 'wb+', buffering=0)
    termios.tcsetattr(sys.stdin, termios.TCSADRAIN, stty_new)

ttyfd.write(b'\033[7\033[r\033[999;999H\033[6n')
ttyfd.flush()

# Put stdin into cbreak mode.
# Python 2 can use fd here, but in Python 3 we have to get sys.stdin.fileno.
tty.setcbreak(sys.stdin)

# Nonblocking mode.
fcntl.fcntl(fileno, fcntl.F_SETFL, fc_old | os.O_NONBLOCK)

try:
    while True:
        if select.select([ttyfd], [], [])[0]:
            output = sys.stdin.read()
            break
finally:
    # Reset the terminal back to normal cooked mode
    termios.tcsetattr(fileno, termios.TCSAFLUSH, stty_old)
    fcntl.fcntl(fileno, fcntl.F_SETFL, fc_old)

rows, cols = list(map(int, re.findall(r'\d+', output)))

fcntl.ioctl(ttyfd, termios.TIOCSWINSZ, struct.pack('HHHH', rows, cols, 0, 0))

sys.stdout.write('set the terminal to {} rows, {} cols\n\n'.format(rows, cols))
