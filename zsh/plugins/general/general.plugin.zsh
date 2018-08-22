# So these commands can be executed with sudo
alias sudo="sudo "

# Easier navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# List hidden
alias lh="ls -a | egrep '^\.'"

# So that Vim colors look correct in tmux
alias tmux="export TERM=xterm-256color; tmux"
