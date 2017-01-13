#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $DIR/utils.sh

ask_for_sudo

print_heading "Installs"

print_subheading "Core packages"
install_package "cURL"             "curl"
install_package "Git"              "git"
install_package "Python 2"         "python"
install_package "PIP"              "python-pip"
install_package "tmux"             "tmux"
install_package "Virtualenv"       "virtualenv"
install_package "Zsh"              "zsh"

print_subheading "Oh My Zsh"
install_oh_my_zsh


print_heading "Symlink dotfiles\n"
symlink "git/gitconfig"                ".gitconfig"
symlink "tmux/tmux.conf"               ".tmux.conf"
symlink "zsh/zshrc"                    ".zshrc"
symlink "zsh/aliases"                  ".aliases"
symlink "zsh/rossmacarthur.zsh-theme"  ".oh-my-zsh/themes/rossmacarthur.zsh-theme"


print_subheading "Complete!"
