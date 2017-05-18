#!/usr/bin/env python

# Modified version of https://github.com/akkana/scripts/blob/master/termsize

import os
import sys
import fcntl
import struct
import re
import termios
import select

fd = sys.stdin.fileno()

tty = open('/dev/tty', 'r+')
tty.write('\033[7\033[r\033[999;999H\033[6n')
tty.flush()

oldterm = termios.tcgetattr(fd)
newattr = oldterm[:]
newattr[3] = newattr[3] & ~termios.ICANON & ~termios.ECHO
termios.tcsetattr(fd, termios.TCSANOW, newattr)

oldflags = fcntl.fcntl(fd, fcntl.F_GETFL)
fcntl.fcntl(fd, fcntl.F_SETFL, oldflags | os.O_NONBLOCK)

try:
    while True:
        read, _, _ = select.select([fd], [], [])
        if read:
            output = sys.stdin.read()
            break
finally:
    termios.tcsetattr(fd, termios.TCSAFLUSH, oldterm)
    fcntl.fcntl(fd, fcntl.F_SETFL, oldflags)

rows, cols = list(map(int, re.findall(r'\d+', output)))
fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))
termios.tcflush(sys.stdin, termios.TCIOFLUSH)
print '\bReset the terminal to {} rows, {} cols.\n'.format(rows, cols)
