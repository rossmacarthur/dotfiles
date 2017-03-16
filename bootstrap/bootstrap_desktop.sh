#!/usr/bin/env bash

. utils.sh
. installs.sh


heading "Installs\n"

execute "sudo apt update" "Update APT"

subheading "Core packages"
install_package "cURL"       "curl"
install_package "Git"        "git"
install_package "GParted"    "gparted"
install_package "htop"       "htop"
install_package "Python 2"   "python"
install_package "Python Dev" "python-dev"
install_package "Pinta"      "pinta"
install_package "tmux"       "tmux"
install_package "xclip"      "xclip"
install_package "Zsh"        "zsh"

subheading "Oh My Zsh"
install_oh_my_zsh

subheading "Python 2 packages"
install_pip
install_pip_package "Click"      "click"
install_pip_package "Flake8"     "flake8"
install_pip_package "PyCrypto"   "pycrypto"
install_pip_package "Pyperclip"  "pyperclip"
install_pip_package "Virtualenv" "virtualenv"

subheading "Sublime Text 3"
install_sublime_text_3

subheading "Google Chrome"
install_google_chrome

subheading "MEGAsync Client"
install_megasync_client

subheading "Spotify Client"
install_spotify_client

subheading "Other"
setup_gnome_terminal_theme
disable_guest_login


heading "Symlink dotfiles\n"

symlink "git/gitconfig"               ".gitconfig"
symlink "tmux/tmux.conf"              ".tmux.conf"
symlink "zsh/zshrc"                   ".zshrc"
symlink "zsh/aliases"                 ".aliases"
symlink "zsh/rossmacarthur.zsh-theme" ".oh-my-zsh/themes/rossmacarthur.zsh-theme"


heading "Install scripts\n"

symlink "bin/serial.sh"             ".local/bin/serial"
symlink "bin/storepass.py"          ".local/bin/storepass"
create_dir                          ".oh-my-zsh/completions/"
symlink "zsh/completions/storepass" ".oh-my-zsh/completions/_storepass"
