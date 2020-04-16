#!/usr/bin/env bash

set -e

if [[ $EUID -ne 0 ]]; then
  echo "This script should be run with root privileges"
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: femtocom <serial-port> [ <speed> [ <stty-options> ... ] ]"
  echo ""
  echo "e.g: femtocom /dev/ttyUSB0 115200"
  echo ""
  echo "Press Ctrl+Q to quit"
  exit 0
fi

original_settings="$(stty -g)"
trap 'set +e; kill "${bg_pid}"; stty "${original_settings}"' EXIT
port="${1}"; shift
stty -F "${port}" raw -echo "$@"
stty raw -echo isig intr ^Q quit undef susp undef
cat "${port}" & bg_pid=$!
cat > "${port}"
