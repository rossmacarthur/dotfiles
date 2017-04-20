#!/usr/bin/env bash

. utils.sh

check_os

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENTDIR="$(dirname "$DIR")"


symlink() {
  create_directory "$(dirname "${HOME}/${2}")"
  execute "ln -fs '${PARENTDIR}/${1}' '${HOME}/${2}'" "${1} → ~/${2}"
  sleep 0.25
}


install_homebrew() {
  if ! command_exists brew; then
    execute "echo | ruby -e '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)'" "Homebrew (install)"
  fi
  execute "brew update" "Homebrew (update)"
}


if [ "${PLATFORM}" == "macOS" ]; then
  install_package() {
    execute "brew install ${2}" "${1}"
  }
else
  install_package() {
    execute "sudo apt -y install ${2}" "${1}"
  }
fi


install_pip() {
  if command_exists pip; then
    execute "pip install --upgrade pip" "PIP"
  else
    execute "curl -LsSo get-pip.py https://bootstrap.pypa.io/get-pip.py" "Download get-pip.py"
    execute "sudo python get-pip.py" "PIP"
    rm -f get-pip.py
  fi
}


if [ "${PLATFORM}" == "macOS" ]; then
  install_pip_package() {
    execute "pip install ${2}" "${1}"
  }
else
  install_pip_package() {
    execute "pip install --user ${2}" "${1}"
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


install_deb_package() {
  local name=$1
  local url=$2
  local output=$(mktemp /tmp/XXXXX)
  execute "curl -LsSo ${output} ${url}" "Download ${name} archive"
  if [ $? -ne 0 ]; then
    return
  fi
  execute "sudo dpkg -i ${output}" "Install ${name}"
  if [ $? -ne 0 ]; then
    execute "sudo apt -y install -f" "Fixing dependencies for ${name}"
    execute "sudo dpkg -i ${output}" "Install ${name}"
  fi
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


install_sublime_text_3() {
  check_package_installed "Sublime Text 3" "sublime-text"
  if [ $? -eq 0 ]; then
    local build=$(curl -Ls https://www.sublimetext.com/3 | python -c "import re,sys;print re.search(r'(?<=The latest build is )(\d\d\d\d)',sys.stdin.read()).groups()[0]")
    if [ ! -z "$build" ]; then
      install_deb_package "Sublime Text 3" \
        "https://download.sublimetext.com/sublime-text_build-${build}_amd64.deb"
    else
      print_error "Unable to check latest Sublime Text 3 build"
    fi
  fi
}


install_google_chrome() {
  check_package_installed "Google Chrome" "google-chrome-stable"
  [ $? -eq 0 ] && install_deb_package "Google Chrome" \
    "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
}


install_megasync_client() {
  check_package_installed "MEGAsync Client" "megasync"
  [ $? -eq 0 ] && install_deb_package "MEGAsync Client" \
    "https://mega.nz/linux/MEGAsync/xUbuntu_16.04/amd64/megasync-xUbuntu_16.04_amd64.deb"
}


disable_guest_login() {
  create_directory "/etc/lightdm/lightdm.conf.d"
  execute 'printf "[SeatDefaults]\nallow-guest=false\n" | sudo tee /etc/lightdm/lightdm.conf.d/50-no-guest.conf' "Disable Guest login"
}
