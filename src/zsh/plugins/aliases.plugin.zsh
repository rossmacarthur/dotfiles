#!/usr/bin/env zsh

# So these commands can be executed with sudo
alias sudo="sudo "

# Easier navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"

# List directory contents
alias l='ls -lah'
alias la='ls -lAh'
alias lh="ls -a | egrep '^\.'"
alias ll='ls -lh'

# Copy of `ggp` in Oh My Zsh Git plugin to push to my usual fork name.
function ggpf() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git push rossmacarthur "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    git push rossmacarthur "${b:=$1}"
  fi
}
compdef _git ggp=git-checkout
