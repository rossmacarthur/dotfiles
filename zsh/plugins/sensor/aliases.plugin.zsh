#!/usr/bin/env zsh

# Run a bunch of stuff and then start tmux
dev() {
  resize
  dmesg -n 1 && echo 'set dmesg level to 1\n'
  echo 'starting tmux\n'
  tmux
}

# Restart keepup service
alias keepup="systemctl restart keepup.service"
