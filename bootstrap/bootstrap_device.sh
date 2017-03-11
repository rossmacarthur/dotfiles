#!/usr/bin/env bash

. utils.sh
. installs.sh


heading "Installs\n"

execute "sudo apt update" "Update APT"

subheading "Core packages"
install_package "cURL"     "curl"
install_package "Git"      "git"
install_package "Python 2" "python"
install_package "tmux"     "tmux"
install_package "Zsh"      "zsh"

subheading "Oh My Zsh"
install_oh_my_zsh

subheading "Python 2 packages"
install_pip
install_pip_package "Virtualenv 15.0.3" "virtualenv==15.0.3"
install_pip_package "Supervisor 3.3.1"  "supervisor==3.3.1"


heading "Symlink dotfiles\n"

symlink "git/gitconfig"               ".gitconfig"
symlink "tmux/tmux.conf"              ".tmux.conf"
symlink "zsh/zshrc"                   ".zshrc"
symlink "zsh/aliases"                 ".aliases"
symlink "zsh/rossmacarthur.zsh-theme" ".oh-my-zsh/themes/rossmacarthur.zsh-theme"
