#!/usr/bin/env bash

source installs.sh

heading "Installs"

subheading "System packages"
execute "sudo apt update" "APT (update)"
install_package "cURL"     "curl"
install_package "Git"      "git"
install_package "Python 2" "python"
install_package "tmux"     "tmux"
install_package "Vim"      "vim"
install_package "Zsh"      "zsh"

subheading "Python 2 packages"
install_pip2
install_pip2_package "Nanocom"    "nanocom"
install_pip2_package "Virtualenv" "virtualenv"

subheading "Oh My Zsh"
clone_oh_my_zsh

subheading "Base16 Shell Theme"
clone_base16_shell_theme

subheading "Vim plugins"
clone_vim_base16_themes


heading "Create symbolic links"

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
