#!/usr/bin/env sh

# Refer: https://developer.apple.com/library/archive/technotes/tn2450/_index.html

usage() {
    cat 1>&2 <<EOF
Remap keyboard keys.

Usage:
    keymap.sh [OPTIONS]

Options:
  -h, --help   Show this message and exit.
      --reset  Reset the keyboard(s) to the original mapping.
EOF
}

set_key_mapping() {
  # Internal Keyboard
  # - Remap Caps Lock to Backspace.
  # - Remap Section sign to Back tick.
  hidutil property --matching '{"VendorID": 0x5ac, "ProductID": 0x27c}' --set '
  {
    "UserKeyMapping": [
      {
        "HIDKeyboardModifierMappingSrc": 0x700000039,
        "HIDKeyboardModifierMappingDst": 0x70000002A
      },
      {
        "HIDKeyboardModifierMappingSrc": 0x700000064,
        "HIDKeyboardModifierMappingDst": 0x700000035
      }
    ]
  }' >/dev/null
  echo "Remapped internal keyboard"

  # External USB keyboard
  # - Remap Caps Lock to Backspace.
  hidutil property --matching '{"VendorID": 0x4d9, "ProductID": 0x269}' --set '
  {
    "UserKeyMapping": [
      {
        "HIDKeyboardModifierMappingSrc": 0x700000039,
        "HIDKeyboardModifierMappingDst": 0x70000002A
      }
    ]
  }' >/dev/null
  echo "Remapped USB keyboard"
}

reset_key_mapping() {
  hidutil property --matching '{"VendorID": 0x5ac, "ProductID": 0x27c}' --set '{"UserKeyMapping": []}' >/dev/null
  echo "Reset internal keyboard"
  hidutil property --matching '{"VendorID": 0x4d9, "ProductID": 0x269}' --set '{"UserKeyMapping": []}' >/dev/null
  echo "Reset USB keyboard"
}

main() {
  while test $# -gt 0
  do
    case $1 in
      --reset)
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
    reset_key_mapping
  else
    set_key_mapping
  fi
}

main "$@"