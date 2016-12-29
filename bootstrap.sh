#!/usr/bin/env bash


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVICE_PACKAGES="curl git htop python python-pip tmux virtualenv zsh"
DESKTOP_PACKAGES="gimp inkscape octave pinta texlive vlc"
SETUP_SSH=false
SETUP_GNOME_TERMINAL=false
COMMAND=""


function show_usage {
  echo "Usage: $0 [OPTIONS] COMMAND"
  echo
  echo "Options:"
  echo "  -h, --help            Show this message and exit."
  echo "  -s, --ssh             Setup up SSH key."
  echo "  -g, --gnome-terminal  Setup up gnome terminal profile."
  echo
  echo "Commands:"
  echo "  dotfiles  Symlink dotfiles."
  echo "  device    Install device packages and symlink dotfiles."
  echo "  desktop   Install device packages, desktop packages, and symlink dotfiles."
  exit 0
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


function confirm {
  read -r -p $'\e[33m'"$1"$' [Y/n] \e[0m' response
  response=${response,,}
  if [[ $response =~ ^(yes|y| ) ]]; then
    return 0
  else
    return 1
  fi  
}


function parse_opts {
  while [ "$1" != "" ]; do
    case $1 in
      -h | --help)
        show_usage
        exit 0;;
      -s | --ssh)
        SETUP_SSH=true;;
      -g | --gnome-terminal)
        SETUP_GNOME_TERMINAL=true;;
      -*)
        error_and_show_usage "Unknown option \""$1"\"";;
      dotfiles | device | desktop)
        COMMAND=$1
        for LAST; do true; done
        if [ $LAST != $1 ]; then
          error_and_show_usage "Unknown option given to \""$1"\" command"
        fi
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


function setup_ssh {
  if [ "$COMMAND" = "desktop" ]; then
    info "Installing xclip"
    apt -y install xclip
    if [ $? -ne 0 ]; then
      error "Failed to install xclip"
    fi
    ssh-keygen -t rsa -b 4096 -N "" -C macarthur.ross@gmail.com
    cat ~/.ssh/id_rsa.pub | xclip
    info "~/.ssh/id_rsa.pub copied to clipboard"
  else
    ssh-keygen -t rsa -b 4096 -N "" -C macarthur.ross@gmail.com
    info "SSH key created. Public key located at ~/.ssh/id_rsa.pub."
  fi
}


function setup_gnome_terminal {
  info "Setting up GNOME Terminal profile"
  BASE_KEY=/org/gnome/terminal/legacy/profiles:
  PROFILE_UUID=$(uuidgen)
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


function install_device_packages {
  for PKG in $DEVICE_PACKAGES; do
    info "Installing "$PKG
    apt -y install $PKG
    if [ $? -ne 0 ]; then
      error "Failed to install "$PKG
    fi
  done

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


function install_desktop_packages {
  for PKG in $DESKTOP_PACKAGES; do
    confirm "Do you want to install "$PKG"?"
    if [ $? -eq 0 ]; then
      info "Installing "$PKG
      apt -y install $PKG
      if [ $? -ne 0 ]; then
        error "Failed to install "$PKG
      fi
    else
      info "Skipping "$PKG
    fi
  done

  # N.B. assumes a 64-bit OS
  confirm "Do you want to install Sublime Text 3?"
  if [ $? -eq 0 ]; then
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
    dpkg -i "sublime-text_build-"$BUILD"_amd64.deb"
    if [ $? -ne 0 ]; then
      error "Failed to install Sublime Text 3"
    fi
    cd - > /dev/null
  else
    info "Skipping Sublime Text 3"
  fi

  # N.B. assumes a 64-bit OS
  confirm "Do you want to install Google Chrome?"
  if [ $? -eq 0 ]; then
    info "Installing Google Chrome"
    cd /tmp
    curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    if [ $? -ne 0 ]; then
      error "Failed to install Google Chrome. Could not download .deb file."
    fi
    dpkg -i google-chrome-stable_current_amd64.deb
    if [ $? -ne 0 ]; then
      apt -y install -f
      dpkg -i google-chrome-stable_current_amd64.deb
      if [ $? -ne 0 ]; then
        error "Failed to install Google Chrome"
      fi
    fi
    cd - > /dev/null
  else
    info "Skipping Google Chrome"
  fi

  confirm "Do you want to install Spotify Client?"
  if [ $? -eq 0 ]; then
    info "Installing Spotify Client"
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
    echo deb http://repository.spotify.com stable non-free | tee /etc/apt/sources.list.d/spotify.list
    apt update
    apt -y install spotify-client
    if [ $? -ne 0 ]; then
      error "Failed to install Spotify Client"
    fi
  else
    info "Skipping Spotify Client"
  fi
}


function symlink_dotfiles {
  info "Symlinking .gitconfig"
  rm -f $HOME/.gitconfig
  ln -s $DIR/dotfiles/git/.gitconfig $HOME/.gitconfig

  info "Symlinking .zshrc and rossmacarthur.zsh-theme"
  rm -f $HOME/.zshrc $HOME/.oh-my-zsh/themes/rossmacarthur.zsh-theme
  ln -s $DIR/dotfiles/zsh/.zshrc $HOME/.zshrc
  ln -s $DIR/dotfiles/zsh/rossmacarthur.zsh-theme $HOME/.oh-my-zsh/themes/rossmacarthur.zsh-theme

  info "Symlinking .tmux.conf"
  rm -f $HOME/.tmux.conf
  ln -s $DIR/dotfiles/tmux/.tmux.conf $HOME/.tmux.conf
}


function main {
  parse_opts $@

  if [[ $EUID -ne 0 ]]; then
    error "This script should be run using sudo"
  fi

  if [ "$SETUP_SSH" != false ]; then
    setup_ssh
  fi

  case "$COMMAND" in
    dotfiles)
      symlink_dotfiles;;
    device)
      install_device_packages
      symlink_dotfiles;;
    desktop)
      install_device_packages
      install_desktop_packages
      symlink_dotfiles;;
  esac

  if [ "$SETUP_GNOME_TERMINAL" != false ]; then
    setup_gnome_terminal
  fi
}

main $@
