#!/usr/bin/env bash

usage() {
    cat 1>&2 <<EOF
Remap keyboard keys.

Usage:
    remap-keys [OPTIONS]

Options:
  -h, --help   Show this message and exit.
      --reset  Reset the keyboard(s) to the original mapping.
EOF
}

# Just in case ~/.cargo/bin is not in PATH
kb-remap() {
  /Users/ross/.cargo/bin/kb-remap "$@"
}

main() {
  while test $# -gt 0
  do
    case $1 in
      -r|-R|--reset|--RESET)
        reset=true
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Error: unrecognized command line argument '$1'" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done

  if [ -n "$reset" ]; then
    kb-remap --name "Apple Internal Keyboard / Trackpad" --reset
    if kb-remap --list | grep "USB Keyboard" &>/dev/null; then
      echo
      kb-remap --name "USB Keyboard" --reset
    fi
  else
    kb-remap --name "Apple Internal Keyboard / Trackpad" --map capslock:delete --swap '0x64:`'
    if kb-remap --list | grep "USB Keyboard" &>/dev/null; then
      echo
      kb-remap --name "USB Keyboard" --map capslock:delete
    fi
  fi
}

main "$@"
