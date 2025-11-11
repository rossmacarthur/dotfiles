#!/usr/bin/env zsh

autoload -U compinit

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

# Change ripgrep default
alias rg="rg --no-heading"
