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
install_pip_package "Virtualenv 15.0.3" "virtualenv==15.0.3"
install_pip_package "Supervisor 3.3.1"  "supervisor==3.3.1"

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
symlink "vim/colors/base16-onedark.vim" ".vim/colors/base16-onedark.vim"
symlink "zsh/zshrc"                     ".zshrc"
symlink "zsh/aliases"                   ".aliases"
symlink "zsh/rossmacarthur.zsh-theme"   ".oh-my-zsh/themes/rossmacarthur.zsh-theme"

subheading "Scripts"
symlink "bin/serial.sh" ".local/bin/serial"
