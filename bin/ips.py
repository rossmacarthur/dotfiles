#!/usr/bin/env python

import re
import subprocess
import sys

try:
    from itertools import izip_longest as zip_longest
except ImportError:
    from itertools import zip_longest


def cmd(cmd):
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = proc.communicate()
    return proc.returncode, bytes(stdout).decode('utf-8'), bytes(stderr).decode('utf-8')


def is_executable(name):
    returncode, _, _ = cmd('which ' + name)
    return returncode == 0


def ips_from_ifconfig():
    """
    Parse interfaces and IP address from ifconfig. This function should work on macOS and Linux.
    """
    returncode, stdout, _ = cmd('ifconfig -a')

    if returncode != 0:
        print('Error: ifconfig returncode {}'.format(returncode))
        sys.exit(2)

    matches = iter(re.split(r'((?:^|(?<=\n))[A-z0-9]+(?=:\s|\s+))', stdout, re.DOTALL)[1:])

    interfaces = list()
    for r in list(zip_longest(matches, matches)):
        ip = re.search(r'(?:(?<=inet addr:)|(?<=inet\s))\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', r[1])
        if ip:
            interfaces.append((r[0], ip.group(0)))

    return interfaces


def main():
    if is_executable('ifconfig'):
        ips = ips_from_ifconfig()
    else:
        print('Error: Not supported; `ifconfig` is required.')
        sys.exit(1)

    if ips:
        maximum_length = max(len(interface) for interface, _ in ips)
        for ip in ips:
            sys.stdout.write('{1:<{0}}  {2}\n'.format(maximum_length, *ip))



if __name__ == '__main__':
    main()
