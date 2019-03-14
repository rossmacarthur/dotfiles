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
    Parse interfaces and IP address from `ifconfig`.

    This function should work on macOS and Linux.
    """
    returncode, stdout, _ = cmd('ifconfig -a')

    if returncode != 0:
        sys.stderr.write('Error: `ifconfig` returned {}\n'.format(returncode))
        sys.exit(2)

    matches = iter(re.split(r'((?:^|(?<=\n))[A-z0-9]+(?=:\s|\s+))', stdout, re.DOTALL)[1:])

    interfaces = []

    for name, info in zip_longest(matches, matches):
        match = re.search(
            r'(?:(?<=inet addr:)|(?<=inet\s))(?P<ip_address>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})',
            info
        )

        if match:
            interfaces.append((name, match.groupdict()['ip_address']))

    return interfaces


def ips_from_ip_address():
    """
    Parse interface and IP address from `ip address show`.
    """
    returncode, stdout, _ = cmd('ip address show')

    if returncode != 0:
        sys.stderr.write('Error: `ip address show` returned {}\n'.format(returncode))
        sys.exit(2)

    interfaces = []

    for line in stdout.split('\n'):
        match = re.search(
            r'inet\s(?P<ip_address>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*\s(?P<name>.*)$',
            line
        )

        if match:
            d = match.groupdict()
            interfaces.append((d['name'], d['ip_address']))

    return interfaces


def main():
    if is_executable('ifconfig'):
        ips = ips_from_ifconfig()
    elif is_executable('ip'):
        ips = ips_from_ip_address()
    else:
        sys.stderr.write('Error: Not supported; `ifconfig` or `ip` is required.\n')
        sys.exit(1)

    if ips:
        maximum_length = max(len(interface) for interface, _ in ips)

        for ip in ips:
            sys.stdout.write('{1:<{0}}  {2}\n'.format(maximum_length, *ip))


if __name__ == '__main__':
    main()
