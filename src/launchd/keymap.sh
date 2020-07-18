#!/usr/bin/env sh

# See: https://developer.apple.com/library/archive/technotes/tn2450/_index.html

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
}'
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
}'
echo "Remapped USB keyboard"
