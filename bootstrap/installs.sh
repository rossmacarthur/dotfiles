#!/usr/bin/env bash

. utils.sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENTDIR="$(dirname "$DIR")"


symlink() {
  create_directory "$(dirname "${HOME}/${2}")"
  execute "ln -fs '${PARENTDIR}/${1}' '${HOME}/${2}'" "${1} → ~/${2}"
  sleep 0.25
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
    execute "brew install ${2} || brew upgrade ${2}" "${1}"
  }
else
  install_package() {
    execute "sudo apt -y install ${2}" "${1}"
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
    execute "pip2 install ${2}" "${1}"
  }
else
  install_pip2_package() {
    execute "pip2 install --user ${2}" "${1}"
  }
fi


if os_is "darwin"; then
  install_pip3_package() {
    execute "pip3 install ${2}" "${1}"
  }
else
  install_pip3_package() {
    execute "pip3 install --user ${2}" "${1}"
  }
fi


clone_git_repository() {
  local name=$1
  local url=$2
  local folder=$3
  local install=1
  if [ -d "${folder}" ]; then
    ask_for_confirmation "${name} is already installed. Reinstall?"
    if answer_is_yes; then
      remove_directory "${folder}"
      install=0
    fi
  else
    install=0
  fi
  if [ $install -eq 0 ]; then
    execute "git clone --depth=1 ${url} ${folder}" "Clone ${name}"
  fi
}


check_package_installed() {
  local name=$1
  local command=$2

  dpkg -s "${command}" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    ask_for_confirmation "${name} is already installed. Reinstall?"
    if answer_is_yes; then
      execute "sudo apt -y remove ${command}" "Remove current ${name}"
      return 0
    fi
  else
    return 0
  fi
  return 1
}


clone_oh_my_zsh() {
  if [ ! -n "${ZSH}" ]; then
    ZSH=~/.oh-my-zsh
  fi
  clone_git_repository "Oh My Zsh" \
    "https://github.com/robbyrussell/oh-my-zsh.git" \
    "${ZSH}"
}


clone_base16_shell_theme() {
  clone_git_repository "Base16 Shell" \
    "https://github.com/chriskempson/base16-shell" \
    "${HOME}/.config/base16-shell"
}


clone_vim_nerdtree_plugin() {
  clone_git_repository "NERDTree" \
    "https://github.com/scrooloose/nerdtree.git" \
    "${HOME}/.vim/bundle/nerdtree"
}


clone_vim_flake8_plugin() {
  clone_git_repository "Flake8" \
    "https://github.com/nvie/vim-flake8.git" \
    "${HOME}/.vim/bundle/flake8"
}


clone_vim_base16_themes() {
  clone_git_repository "Base16" \
    "https://github.com/chriskempson/base16-vim" \
    "${HOME}/.vim/colors/base16"
  execute "cp ${HOME}/.vim/colors/base16/colors/*.vim ${HOME}/.vim/colors/" "Copy Base16 color schemes to ~/.vim/colors/"
}
