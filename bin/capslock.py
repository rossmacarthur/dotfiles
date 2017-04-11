#!/usr/bin/env python

import sys
from ctypes import cdll, c_uint


def set_capslock(bool):
    X11 = cdll.LoadLibrary("libX11.so.6")
    display = X11.XOpenDisplay(None)
    X11.XkbLockModifiers(display, c_uint(0x0100), c_uint(2), c_uint(2 if bool else 0))
    X11.XCloseDisplay(display)


if len(sys.argv) == 2 and sys.argv[1] in ['on', 'off']:
    set_capslock(sys.argv[1] == 'on')
else:
    print 'Usage: {} on|off'.format(sys.argv[0])
