#!/usr/bin/env zsh

# Ensure fd works
alias fd="fdfind"

# Lock screen
alias afk="gnome-screensaver-command -l"

# Copy to clipboard
alias copy="xclip -selection clipboard"

# Set keyboard to Colemak
cm() {
  setxkbmap us -variant colemak
  xset r 66
  echo "Keyboard set to Colemak"
}

# Set keyboard to QWERTY
qw() {
  setxkbmap us
  xset -r 66
  echo "Keyboard set to QWERTY"
}
