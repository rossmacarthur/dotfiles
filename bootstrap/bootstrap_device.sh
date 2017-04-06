#!/usr/bin/env bash

. utils.sh
. installs.sh


heading "Installs"

subheading "System packages"
execute "sudo apt update" "Update APT"
install_package "cURL"     "curl"
install_package "Git"      "git"
install_package "Python 2" "python"
install_package "tmux"     "tmux"
install_package "Vim"      "vim"
install_package "Zsh"      "zsh"

subheading "Python 2 packages"
install_pip
install_pip_package "Flake8" "flake8"

subheading "Oh My Zsh"
clone_oh_my_zsh

subheading "Base16 Shell Theme"
clone_base16_shell_theme

subheading "Vim plugins"
clone_vim_nerdtree_plugin
clone_vim_flake8_plugin
clone_vim_base16_themes


heading "Create symbolic links"

subheading "Configurations"
symlink "git/gitconfig"                 ".gitconfig"
symlink "tmux/tmux.conf"                ".tmux.conf"
symlink "vim/vimrc"                     ".vimrc"
symlink "zsh/zshrc"                     ".zshrc"
symlink "zsh/aliases_device"            ".aliases"
symlink "zsh/rossmacarthur.zsh-theme"   ".oh-my-zsh/themes/rossmacarthur.zsh-theme"

subheading "Scripts"
symlink "bin/serial.sh" ".local/bin/serial"
