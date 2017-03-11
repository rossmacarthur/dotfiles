#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENTDIR="$(dirname "$DIR")"


symlink() {
  execute "ln -fs '${PARENTDIR}/${1}' '${HOME}/${2}'" "${1} →  ~/${2}"
}


create_dir() {
  execute "mkdir -p ${HOME}/${1}" "Create directory ~/${1}"
}


install_package() {
  execute "sudo apt -y install ${2}" "${1}"
}


install_pip() {
  if command_exists pip; then
    execute "pip install --upgrade pip" "PIP"
  else
    execute "curl -LsSo get-pip.py https://bootstrap.pypa.io/get-pip.py" "Download get-pip.py"
    execute "sudo python get-pip.py" "PIP"
    rm -f get-pip.py
  fi
}


install_pip_package() {
  execute "pip install --user ${2}" "${1}"
}


install_oh_my_zsh() {
  if [ ! -n "${ZSH}" ]; then 
    ZSH=~/.oh-my-zsh 
  fi
  if [ -d "${ZSH}" ]; then
    ask_for_confirmation "Oh My Zsh installation detected. Overwrite?"
    if answer_is_yes; then
      execute "rm -rf ${ZSH}" "Remove directory ${ZSH}"
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
  local reinstall=1

  if [ $installed -eq 0 ]; then
    ask_for_confirmation "Sublime Text 3 is already installed. Reinstall?"
    answer_is_yes
    reinstall=$?
  fi

  if [ $reinstall -eq 0 ]; then
    execute "sudo apt -y remove sublime-text" "Remove current install"
  fi

  if [ $installed -ne 0 ] || [ $reinstall -eq 0 ]; then
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
  local reinstall=1

  if [ $installed -eq 0 ]; then
    ask_for_confirmation "Google Chrome is already installed. Reinstall?"
    answer_is_yes
    reinstall=$?
  fi

  if [ $reinstall -eq 0 ]; then
    execute "sudo apt -y remove google-chrome-stable" "Remove current install"
  fi

  if [ $installed -ne 0 ] || [ $reinstall -eq 0 ]; then
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
  local reinstall=1

  if [ $installed -eq 0 ]; then
    ask_for_confirmation "MEGAsync Client is already installed. Reinstall?"
    answer_is_yes
    reinstall=$?
  fi

  if [ $reinstall -eq 0 ]; then
    execute "sudo apt -y remove megasync" "Remove current install"
  fi

  if [ $installed -ne 0 ] || [ $reinstall -eq 0 ]; then
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
  command_exists spotify
  local installed=$?
  local reinstall=1

  if [ $installed -eq 0 ]; then
    ask_for_confirmation "Spotify Client is already installed. Reinstall?"
    answer_is_yes
    reinstall=$?
  fi

  if [ $reinstall -eq 0 ]; then
    execute "sudo apt -y remove spotify-client" "Remove current install"
  fi

  if [ $installed -ne 0 ] || [ $reinstall -eq 0 ]; then
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
  else
    print_in_yellow "   [!] Skipping\n"
  fi
}


_setup_gnome_terminal_theme() {
  local base_key=/org/gnome/terminal/legacy/profiles:
  local profile_uuid=$(uuidgen)

  dconf reset -f $base_key/
  if [ $? -ne 0 ]; then
    return 1
  fi
  dconf write "$base_key/list" "['$profile_uuid']"
  if [ $? -ne 0 ]; then
    return 1
  fi
  dconf load $base_key/:$profile_uuid/ <<EOL
[/]
foreground-color='#c0c5ce'
visible-name='Ross MacArthur'
palette=['#2b303b', '#bf616a', '#a3be8c', '#ebcb8b', '#8fa1b3', '#b48ead', '#96b5b4', '#c0c5ce', '#65737e', '#bf616a', '#a3be8c', '#ebcb8b', '#8fa1b3', '#b48ead', '#96b5b4', '#eff1f5']
use-theme-colors=false
use-theme-transparency=false
use-theme-background=false
bold-color-same-as-fg=true
bold-color='#c0c5ce'
background-color='#2b303b'
EOL
  return $?
}
setup_gnome_terminal_theme() {
  execute "_setup_gnome_terminal_theme" "Install Gnome Terminal theme"
}


_disable_guest_login() {
  sudo mkdir -p /etc/lightdm/lightdm.conf.d
  sudo sh -c 'printf "[SeatDefaults]\nallow-guest=false\n" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf'
}
disable_guest_login() {
  execute "_disable_guest_login" "Disable Guest login"
}
