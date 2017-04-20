#!/usr/bin/env bash

. installs.sh


heading "Installs"

subheading "System packages"
install_homebrew
install_package "cURL"       "curl"
install_package "Git"        "git"
install_package "htop"       "htop"
install_package "Python 2"   "python"
install_package "tmux"       "tmux"
install_package "Vim"        "vim --with-override-system-vi"
install_package "Zsh"        "zsh"

subheading "Python 2 packages"
install_pip
install_pip_package "Click"      "click"
install_pip_package "Flake8"     "flake8"
install_pip_package "PyCrypto"   "pycrypto"
install_pip_package "Pyperclip"  "pyperclip"
install_pip_package "PypSerial"  "pyserial"
install_pip_package "Virtualenv" "virtualenv"

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
symlink "git/gitconfig"               ".gitconfig"
symlink "git/gitconfig_global"        ".gitconfig_global"
symlink "tmux/tmux.conf"              ".tmux.conf"
symlink "vim/vimrc"                   ".vimrc"
symlink "zsh/zshrc"                   ".zshrc"
symlink "zsh/aliases_macOS"           ".aliases"
symlink "zsh/rossmacarthur.zsh-theme" ".oh-my-zsh/themes/rossmacarthur.zsh-theme"

subheading "Scripts"
symlink "bin/nanocom.py"            ".local/bin/nanocom"
symlink "bin/storepass.py"          ".local/bin/storepass"
symlink "zsh/completions/storepass" ".oh-my-zsh/completions/_storepass"
