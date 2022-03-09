#!/usr/bin/env zsh

if [[ "$TERMINAL_EMULATOR" = *JetBrains* ]]; then
  bindkey "\e\eOD" beginning-of-line
  bindkey "\e\eOC" end-of-line
fi
