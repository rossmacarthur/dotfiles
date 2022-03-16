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

# Alias for a common typo
alias jsut=just

function ggpf() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git push origin "${*}" --force
  else
    [[ "$#" == 0 ]] && local b="$(git_current_branch)"
    git push origin "${b:=$1}" --force
  fi
}
compdef _git ggpf=git-checkout
