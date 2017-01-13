#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENTDIR="$(dirname "$DIR")"


symlink() {
  execute "ln -fs '${PARENTDIR}/${1}' '${HOME}/${2}'" "${1} →  ~/${2}"
}


install_package() {
  execute "sudo apt -y install ${2}" "${1}"
}


install_pip() {
  if command_exists pip; then
    execute "pip install --upgrade pip" "PIP"
  else
    execute "curl -LsSo get-pip.py https://bootstrap.pypa.io/get-pip.py" "Download get-pip.py"
    execute "python get-pip.py" "PIP"
    rm -f get-pip.py
  fi
}


install_pip3() {
  if command_exists pip3; then
    execute "pip3 install --upgrade pip" "PIP 3"
  else
    execute "curl -LsSo get-pip.py https://bootstrap.pypa.io/get-pip.py" "Download get-pip.py"
    execute "python3 get-pip.py" "PIP 3"
    rm -f get-pip.py
  fi
}


install_pip_package() {
  execute "pip install --user ${2}" "${1}"
}


install_pip3_package() {
  execute "pip3 install --user ${2}" "${1}"
}


install_oh_my_zsh() {
  if [ ! -n "${ZSH}" ]; then 
    ZSH=~/.oh-my-zsh 
  fi
  if [ -d "${ZSH}" ]; then
    ask_for_confirmation "Oh My Zsh installation detected. Overwrite?"
    if answer_is_yes; then
      execute "rm -rf ${ZSH}" "Remove ${ZSH}"
      execute "env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ${ZSH}" "Clone Oh My Zsh from GitHub"
    else
      print_in_yellow "   [!] Skipping\n"
    fi
  else
    execute "env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ${ZSH}" "Clone Oh My Zsh from GitHub"
  fi
}


install_sublime_text_3() {
  command_exists subl
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
  command_exists google-chrome-stable
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
  command_exists megasync
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
