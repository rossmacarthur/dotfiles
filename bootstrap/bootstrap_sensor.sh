#!/usr/bin/env bash

request_sudo || abort

subheading "System packages"
execute "sudo apt update" "APT (update)"
install_package "curl" "cURL"
install_package "git" "Git"
install_package "python" "Python 2"
install_package "tmux"
install_package "vim" "Vim"
install_package "zsh" "Zsh"

subheading "Python packages"
install_pip
install_pip_package "nanocom"
install_pip_package "setuptools"
install_pip_package "virtualenv"
install_pip_package "wheel"

subheading "Remote repositories"
clone_oh_my_zsh
clone_base16_shell_theme

subheading "Vim plugins"
clone_vim_base16_themes

subheading "Configurations"
symlink "git/gitconfig"        ".gitconfig"
symlink "git/gitignore_global" ".gitignore_global"
symlink "tmux/tmux.conf"       ".tmux.conf"
symlink "vim/vimrc"            ".vimrc"
symlink "zsh/aliases/sensor"   ".aliases"
symlink "zsh/plugins/sensor"   ".plugins"
symlink "zsh/zshrc"            ".zshrc"

subheading "Scripts"
symlink "bin/femtocom.sh"  ".local/bin/femtocom"
symlink "bin/gensshkey.sh" ".local/bin/gensshkey"
symlink "bin/ips.py"       ".local/bin/ips"
symlink "bin/resize.py"    ".local/bin/resize"
