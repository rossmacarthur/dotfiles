#!/usr/bin/env bash

source installs.sh

heading "Installs"

subheading "System packages"
update_package_manager

install_package "cURL"         "curl"
install_package "Git"          "git"
install_package "htop"         "htop"
install_package "Python 2"     "python"
install_package "Python 2 Dev" "python-dev"
install_package "Python 3"     "python3"
install_package "Python 3 Dev" "python3-dev"
install_package "tmux"         "tmux"
install_package "Vim"          "vim"
install_package "Zsh"          "zsh"

subheading "Python 3 packages"
install_pip3
install_pip3_package "Virtualenv"  "virtualenv"

subheading "Oh My Zsh"
clone_oh_my_zsh

subheading "Base16 Shell Theme"
clone_base16_shell_theme

subheading "Vim plugins"
clone_vim_flake8_plugin
clone_vim_base16_themes


heading "Create symbolic links"

subheading "Configurations"
symlink "git/gitconfig"        ".gitconfig"
symlink "git/gitignore_global" ".gitignore_global"
symlink "tmux/tmux.conf"       ".tmux.conf"
symlink "vim/vimrc"            ".vimrc"
symlink "zsh/plugins/server"   ".plugins"
symlink "zsh/zshrc"            ".zshrc"

subheading "Scripts"
symlink "bin/gensshkey.sh" ".local/bin/gensshkey"
symlink "bin/ips.py"       ".local/bin/ips"
