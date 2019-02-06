#!/usr/bin/env bash

source utils.sh

BOOTSTRAP_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIRECTORY="$(dirname "$BOOTSTRAP_DIRECTORY")"


symlink() {
  create_directory "$(dirname "$HOME/$2")"
  execute "ln -fs '$DOTFILES_DIRECTORY/$1' '$HOME/$2'" "$1 → ~/$2"
  sleep 0.1
}


sync() {
  create_directory "$(dirname "$HOME/$2")"
  execute "rsync '$DOTFILES_DIRECTORY/$1' '$HOME/$2'" "$1 → ~/$2"
  sleep 0.1
}


if os_is "darwin"; then
  update_package_manager() {
    if ! command_exists brew; then
      execute "echo | ruby -e '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)'" "Homebrew (install)"
    fi
    execute "brew update" "Homebrew (update)"
  }
else
  update_package_manager() {
    execute "sudo apt update" "APT (update)"
  }
fi


if os_is "darwin"; then
  install_package() {
    execute "brew install $2 || brew upgrade $2" "$1"
  }
else
  install_package() {
    execute "sudo apt -y install $2" "$1"
  }
fi


install_pip2() {
  if command_exists pip2; then
    execute "pip2 install --upgrade pip" "PIP 2"
  else
    execute "curl -LsSo get-pip.py https://bootstrap.pypa.io/get-pip.py" "Download get-pip.py"
    execute "sudo python2 get-pip.py" "PIP 2"
    rm -f get-pip.py
  fi
}


install_pip3() {
  if command_exists pip3; then
    execute "pip3 install --upgrade pip" "PIP 3"
  else
    execute "curl -LsSo get-pip.py https://bootstrap.pypa.io/get-pip.py" "Download get-pip.py"
    execute "sudo python3 get-pip.py" "PIP 3"
    rm -f get-pip.py
  fi
}


if os_is "darwin"; then
  install_pip2_package() {
    execute "pip2 install $2" "$1"
  }
else
  install_pip2_package() {
    execute "pip2 install --user $2" "$1"
  }
fi


if os_is "darwin"; then
  install_pip3_package() {
    execute "pip3 install $2" "$1"
  }
else
  install_pip3_package() {
    execute "pip3 install --user $2" "$1"
  }
fi


clone_git_repository() {
  local name=$1
  local url=$2
  local folder=$3
  local install=false
  if [ -d "$folder" ]; then
    if ask_for_confirmation "$name is already installed. Reinstall?"; then
      remove_directory "$folder"
      install=true
    fi
  else
    install=true
  fi
  if [ "$install" = true ]; then
    execute "git clone --depth=1 $url $folder" "Clone $name"
  fi
}


check_package_installed() {
  local name=$1
  local command=$2
  if dpkg -s "$command" > /dev/null 2>&1; then
    if ask_for_confirmation "$name is already installed. Reinstall?"; then
      execute "sudo apt -y remove $command" "Remove current $name" && return 0 || return 1
    fi
  else
    return 0
  fi
}


clone_oh_my_zsh() {
  if [ ! -n "$ZSH" ]; then
    ZSH=~/.oh-my-zsh
  fi
  clone_git_repository "Oh My Zsh" \
    "https://github.com/rossmacarthur/oh-my-zsh.git" \
    "$ZSH"
}


clone_base16_shell_theme() {
  clone_git_repository "Base16 Shell" \
    "https://github.com/chriskempson/base16-shell" \
    "$HOME/.config/base16-shell"
}


clone_vim_flake8_plugin() {
  clone_git_repository "Flake8" \
    "https://github.com/nvie/vim-flake8.git" \
    "$HOME/.vim/bundle/flake8"
}


clone_vim_base16_themes() {
  clone_git_repository "Base16" \
    "https://github.com/chriskempson/base16-vim" \
    "$HOME/.vim/colors/base16"
  execute "cp $HOME/.vim/colors/base16/colors/*.vim $HOME/.vim/colors/" "Copy Base16 color schemes to ~/.vim/colors/"
}
