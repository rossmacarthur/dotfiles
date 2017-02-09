#!/usr/bin/env bash

. utils.sh
. installs.sh

ask_for_sudo


heading "Installs\n"

execute "sudo apt update" "Update APT"
execute "sudo apt -y upgrade" "Upgrade packages"

subheading "Core packages"
install_package "cURL"       "curl"
install_package "Git"        "git"
install_package "GParted"    "gparted"
install_package "htop"       "htop"
install_package "Python 2"   "python"
install_package "Python 3"   "python3"
install_package "Pinta"      "pinta"
install_package "Screen"     "screen"
install_package "TeX Live"   "texlive-full"
install_package "tmux"       "tmux"
install_package "Virtualenv" "virtualenv"
install_package "xclip"      "xclip"
install_package "Zsh"        "zsh"

subheading "Oh My Zsh"
install_oh_my_zsh

subheading "Python 2 packages"
install_pip
install_pip_package "Click"      "click"
install_pip_package "Flake8"     "flake8"
install_pip_package "Matplotlib" "matplotlib"
install_pip_package "NumPy"      "numpy"
install_pip_package "PyCrypto"   "pycrypto"
install_pip_package "Pyperclip"  "pyperclip"

subheading "Python 3 packages"
install_pip3
install_pip3_package "Click"     "click"
install_pip3_package "TrueSkill" "trueskill"

subheading "Sublime Text 3"
install_sublime_text_3

subheading "Google Chrome"
install_google_chrome

subheading "MEGAsync Client"
install_megasync_client

subheading "Spotify Client"
install_spotify_client


heading "Symlink dotfiles\n"
symlink "git/gitconfig"               ".gitconfig"
symlink "tmux/tmux.conf"              ".tmux.conf"
symlink "zsh/zshrc"                   ".zshrc"
symlink "zsh/aliases"                 ".aliases"
symlink "zsh/rossmacarthur.zsh-theme" ".oh-my-zsh/themes/rossmacarthur.zsh-theme"


heading "Install scripts\n"
symlink "bin/storepass.py" ".local/bin/storepass"
