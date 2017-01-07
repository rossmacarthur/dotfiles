#!/usr/bin/env bash

source bootstrap.env

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


function show_usage {
  echo "Usage: $0 [OPTIONS] COMMAND"
  echo
  echo "Options:"
  echo "  -h, --help  Show this message and exit."
  echo
  echo "Commands:"
  echo "  configure  Edit the configuration file."
  echo "  dotfiles   Symlink dotfiles."
  echo "  device     Install device packages and symlink dotfiles."
  echo "  desktop    Install device packages, desktop packages, and symlink dotfiles."
}


function error {
  echo -e "\033[31mERROR: $1\033[m" >&2
  exit 1
}


function info {
  echo -e "\033[32mINFO:  $1\033[m"
}


function error_and_show_usage {
  echo -e "\033[31mERROR: $1\033[m" >&2
  echo
  show_usage
  exit 1
}


function parse_opts {
  while [ "$1" != "" ]; do
    case $1 in
      -h | --help)
        show_usage
        exit 0;;
      -*)
        error_and_show_usage "Unknown option \""$1"\"";;
      configure | dotfiles | device | desktop)
        COMMAND=$1
        break;;
      *)
        error_and_show_usage "Unknown command \""$1"\"";;
    esac
    shift
  done

  if [ "$COMMAND" = "" ]; then
    error_and_show_usage "No command given"
  fi
}


function symlink_dotfiles {
  info "Symlinking gitconfig"
  rm -f $HOME/.gitconfig
  ln -s $DIR/dotfiles/git/gitconfig $HOME/.gitconfig

  info "Symlinking zshrc and rossmacarthur.zsh-theme"
  rm -f $HOME/.zshrc $HOME/.oh-my-zsh/themes/rossmacarthur.zsh-theme
  ln -s $DIR/dotfiles/zsh/zshrc $HOME/.zshrc
  ln -s $DIR/dotfiles/zsh/rossmacarthur.zsh-theme $HOME/.oh-my-zsh/themes/rossmacarthur.zsh-theme

  info "Symlinking tmux.conf"
  rm -f $HOME/.tmux.conf
  ln -s $DIR/dotfiles/tmux/tmux.conf $HOME/.tmux.conf
}


function install_packages {
  for pkg in $1; do
    info "Installing ${pkg}"
    sudo apt -y install $pkg
    if [ $? -ne 0 ]; then
      error "Failed to install ${pkg}"
    fi
  done
}


function install_pip_packages {
  for pkg in $1; do
    info "Installing Python module ${pkg}"
    pip install --user $pkg --upgrade pip
    if [ $? -ne 0 ]; then
      error "Failed to install ${pkg}"
    fi
  done
}


function install_pip3_packages {
  for pkg in $1; do
    info "Installing Python 3 module ${pkg}"
    pip3 install --user $pkg --upgrade pip
    if [ $? -ne 0 ]; then
      error "Failed to install ${pkg}"
    fi
  done
}


function install_oh_my_zsh {
  if [ ! -n "$ZSH" ]; then 
    ZSH=~/.oh-my-zsh 
  fi
  if [ -d "$ZSH" ]; then
    info "Folder ~/.oh-my-zsh exists. Skipping Oh My Zsh installation."
  else
    info "Installing Oh My Zsh"
    env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH
    if [ $? -ne 0 ]; then
      error "Failed to install Oh My Zsh"
    fi
  fi
}


function install_sublime_text_3 {
  # N.B. assumes a 64-bit OS
  hash subl
  if [ $? -ne 0 ]; then
    info "Installing Sublime Text 3"
    BUILD=$(curl -s -L www.sublimetext.com/3 | python -c \
           "import re,sys;print re.search(r'(?<=The latest build is )(\d\d\d\d)',sys.stdin.read()).groups()[0]")
    if [ $? -ne 0 ]; then
      error "Failed to install Sublime Text 3. Could not latest build."
    fi
    cd /tmp
    curl -O "https://download.sublimetext.com/sublime-text_build-"$BUILD"_amd64.deb"
    if [ $? -ne 0 ]; then
      error "Failed to install Sublime Text 3. Could not download .deb file."
    fi
    sudo dpkg -i "sublime-text_build-"$BUILD"_amd64.deb"
    if [ $? -ne 0 ]; then
      error "Failed to install Sublime Text 3"
    fi
    cd - > /dev/null
  else
    info "Sublime Text 3 already installed. Skipping."
  fi
}


function install_megasync_client {
  # N.B. assumes a 64-bit OS
  hash megasync
  if [ $? -ne 0 ]; then
    info "Installing MEGAsync Client"
    cd /tmp
    curl -O https://mega.nz/linux/MEGAsync/xUbuntu_16.04/amd64/megasync-xUbuntu_16.04_amd64.deb
    if [ $? -ne 0 ]; then
      error "Failed to install MEGAsync Client. Could not download .deb file."
    fi
    sudo dpkg -i megasync-xUbuntu_16.04_amd64.deb
    if [ $? -ne 0 ]; then
      sudo apt -y install -f
      sudo dpkg -i megasync-xUbuntu_16.04_amd64.deb
      if [ $? -ne 0 ]; then
        error "Failed to install MEGAsync Client"
      fi
    fi
    cd - > /dev/null
  else
    info "MEGAsync Client already installed. Skipping."
  fi
}


function install_google_chrome {
  # N.B. assumes a 64-bit OS
  hash google-chrome-stable
  if [ $? -ne 0 ]; then
    info "Installing Google Chrome"
    cd /tmp
    curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    if [ $? -ne 0 ]; then
      error "Failed to install Google Chrome. Could not download .deb file."
    fi
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    if [ $? -ne 0 ]; then
      sudo apt -y install -f
      sudo dpkg -i google-chrome-stable_current_amd64.deb
      if [ $? -ne 0 ]; then
        error "Failed to install Google Chrome"
      fi
    fi
    cd - > /dev/null
  else
    info "Google Chrome already installed. Skipping."
  fi
}


function install_spotify_client {
  hash spotify
  if [ $? -ne 0 ]; then
    info "Installing Spotify Client"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
    echo deb http://repository.spotify.com stable non-free | tee /etc/apt/sources.list.d/spotify.list
    sudo apt update
    sudo apt -y install spotify-client
    if [ $? -ne 0 ]; then
      error "Failed to install Spotify Client"
    fi
  else
    info "Spotify Client already installed. Skipping."
  fi
}


function setup_ssh {
  if [ -e ~/.ssh/id_rsa.pub ]; then
    info "File ~/.ssh/id_rsa.pub exists. Skipping SSH setup."
  else
    if [ "$COMMAND" = "desktop" ]; then
      info "Installing xclip"
      sudo apt -y install xclip
      if [ $? -ne 0 ]; then
        info "Failed to install xclip"
        ssh-keygen -t rsa -b 4096 -N "" -C macarthur.ross@gmail.com
        info "SSH key created. Public key located at ~/.ssh/id_rsa.pub."
      else
        ssh-keygen -t rsa -b 4096 -N "" -C macarthur.ross@gmail.com
        cat ~/.ssh/id_rsa.pub | xclip -selection c
        info "~/.ssh/id_rsa.pub copied to clipboard"
      fi
    else
      ssh-keygen -t rsa -b 4096 -N "" -C macarthur.ross@gmail.com
      info "SSH key created. Public key located at ~/.ssh/id_rsa.pub."
    fi
  fi
}


function setup_gnome_terminal {
  info "Setting up GNOME Terminal profile"
  local BASE_KEY=/org/gnome/terminal/legacy/profiles:
  local PROFILE_UUID=$(uuidgen)
  dconf reset -f $BASE_KEY/
  dconf write "$BASE_KEY/list" "['$PROFILE_UUID']"
  dconf load $BASE_KEY/:$PROFILE_UUID/ <<EOL
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
  if [ $? -ne 0 ]; then
    error "Failed to setup up GNOME Terminal profile"
  fi
}


function device_setup {
  install_packages "${DEVICE_PACKAGES}"

  install_pip_packages "${DEVICE_PIP}"

  if [ "${DEVICE_OH_MY_ZSH}" = true ]; then
    install_oh_my_zsh
  fi

  symlink_dotfiles

  if [ "${DEVICE_SSH}" = true ]; then
    setup_ssh
  fi
}


function desktop_setup {
  install_packages "${DESKTOP_PACKAGES}"

  install_pip_packages "${DESKTOP_PIP}"

  install_pip3_packages "${DESKTOP_PIP3}"

  if [ "${DESKTOP_OH_MY_ZSH}" = true ]; then
    install_oh_my_zsh
  fi

  if [[ "${DESKTOP_DEB}" == *"sublime-text"* ]]; then
    install_sublime_text_3
  fi

  if [[ "${DESKTOP_DEB}" == *"google-chrome"* ]]; then
    install_google_chrome
  fi

  if [[ "${DESKTOP_DEB}" == *"megasync-client"* ]]; then
    install_megasync_client
  fi

  if [[ "${DESKTOP_DEB}" == *"spotify-client"* ]]; then
    install_spotify_client
  fi

  symlink_dotfiles

  if [ "${DESKTOP_UBUNTU}" = true ]; then
    setup_gnome_terminal
    info "Disabling guest login"
    sudo mkdir -p /etc/lightdm/lightdm.conf.d
    sudo sh -c 'printf "[SeatDefaults]\nallow-guest=false\n" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf'
    install_packages "unity-tweak-tool"
  fi

  if [ "${DESKTOP_SSH}" = true ]; then
    setup_ssh
  fi
}


function main {
  parse_opts $@

  case "$COMMAND" in
    configure)
      "${EDITOR:-nano}" bootstrap.env;;
    dotfiles)
      symlink_dotfiles;;
    device)
      device_setup;;
    desktop)
      desktop_setup;;
  esac
}

main $@
