#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $DIR/utils.sh


install_sublime_text_3() {
  hash subl
  local installed=$?
  local reinstall=0
  if [ $installed -eq 0 ]; then
    ask_for_confirmation "Sublime Text 3 is already installed. Reinstall?"
    reinstall=answer_is_yes
  fi

  if $reinstall; then
    execute "sudo apt -y remove sublime-text" "Remove current install"
  fi

  if [ $installed -ne 0 ] || $reinstall; then
    BUILD=$(curl -s -L www.sublimetext.com/3 | python -c \
            "import re,sys;print re.search(r'(?<=The latest build is )(\d\d\d\d)',sys.stdin.read()).groups()[0]")
    execute "curl -O https://download.sublimetext.com/sublime-text_build-${BUILD}_amd64.deb" "Download archive"
    if [ $? -ne 0 ]; then
      return
    fi
    execute "sudo dpkg -i sublime-text_build-${BUILD}_amd64.deb" "Install Sublime Text 3"
    if [ $? -ne 0 ]; then
      execute "sudo apt -y install -f" "Fixing dependencies"
      execute "sudo dpkg -i sublime-text_build-${BUILD}_amd64.deb" "Install Sublime Text 3"
    fi
  else
    print_in_yellow "   [!] Skipping\n"
  fi
}


install_google_chrome() {
  hash google-chrome-stable
  local installed=$?
  local reinstall=0
  if [ $installed -eq 0 ]; then
    ask_for_confirmation "Google Chrome is already installed. Reinstall?"
    reinstall=answer_is_yes
  fi

  if $reinstall; then
    execute "sudo apt -y remove google-chrome-stable" "Remove current install"
  fi

  if [ $installed -ne 0 ] || $reinstall; then
    execute "curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" "Download archive"
    if [ $? -ne 0 ]; then
      return
    fi
    execute "sudo dpkg -i google-chrome-stable_current_amd64.deb" "Install Google Chrome"
    if [ $? -ne 0 ]; then
      execute "sudo apt -y install -f" "Fixing dependencies"
      execute "sudo dpkg -i google-chrome-stable_current_amd64.deb" "Install Google Chrome"
    fi
  else
    print_in_yellow "   [!] Skipping\n"
  fi
}


install_megasync_client() {
  hash megasync
  local installed=$?
  local reinstall=0
  if [ $installed -eq 0 ]; then
    ask_for_confirmation "MEGAsync Client is already installed. Reinstall?"
    reinstall=answer_is_yes
  fi

  if $reinstall; then
    execute "sudo apt -y remove megasync" "Remove current install"
  fi

  if [ $installed -ne 0 ] || $reinstall; then
    execute "curl -O https://mega.nz/linux/MEGAsync/xUbuntu_16.04/amd64/megasync-xUbuntu_16.04_amd64.deb" "Download archive"
    if [ $? -ne 0 ]; then 
      return
    fi
    execute "sudo dpkg -i megasync-xUbuntu_16.04_amd64.deb" "Install MEGAsync Client"
    if [ $? -ne 0 ]; then
      execute "sudo apt -y install -f" "Fixing dependencies"
      execute "sudo dpkg -i megasync-xUbuntu_16.04_amd64.deb" "Install MEGAsync Client"
    fi
  else
    print_in_yellow "   [!] Skipping\n"
  fi
}


install_spotify_client() {
  execute "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886" "Add signing key"
  if [ $? -ne 0 ]; then
    return
  fi
  execute "echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list" "Add respository"
  if [ $? -ne 0 ]; then 
    return
  fi
  execute "sudo apt update" "Update APT"
  execute "sudo apt -y install spotify-client" "Install Spotify Client"
}


ask_for_sudo

print_heading "Installs"
print_subheading "Core packages"
install_package "cURL"             "curl"
install_package "Git"              "git"
install_package "GParted"          "gparted"
install_package "htop"             "htop"
install_package "Python 2"         "python"
install_package "PIP"              "python-pip"
install_package "Python 3"         "python3"
install_package "PIP 3"            "python3-pip"
install_package "Pinta"            "pinta"
install_package "Screen"           "screen"
install_package "TeX Live"         "texlive-full"
install_package "tmux"             "tmux"
install_package "Virtualenv"       "virtualenv"
install_package "xclip"            "xclip"
install_package "Zsh"              "zsh"

print_subheading "Oh My Zsh"
install_oh_my_zsh

print_subheading "Python 2 packages"
install_pip_package "Click"        "click"
install_pip_package "Flake8"       "flake8"
install_pip_package "Matplotlib"   "matplotlib"
install_pip_package "NumPy"        "numpy"
install_pip_package "PyCrypto"     "pycrypto"
install_pip_package "Pyperclip"    "pyperclip"

print_subheading "Python 3 packages"
install_pip3_package "Click"       "click"
install_pip3_package "TrueSkill"   "trueskill"

print_subheading "Sublime Text 3"
install_sublime_text_3

print_subheading "Google Chrome"
install_google_chrome

print_subheading "MEGAsync Client"
install_megasync_client

print_subheading "Spotify Client"
install_spotify_client


print_heading "Symlink dotfiles\n"
symlink "git/gitconfig"                ".gitconfig"
symlink "tmux/tmux.conf"               ".tmux.conf"
symlink "zsh/zshrc"                    ".zshrc"
symlink "zsh/aliases"                  ".aliases"
symlink "zsh/rossmacarthur.zsh-theme"  ".oh-my-zsh/themes/rossmacarthur.zsh-theme"


print_subheading "Complete!"
