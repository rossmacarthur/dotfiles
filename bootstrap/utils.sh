#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENTDIR="$(dirname "$DIR")"


ask_for_sudo() {
  sudo -v &> /dev/null
}


ask_for_confirmation() {
  print_in_yellow "   [?] ${1} (y/n) "
  read -r -n 1 -t 5
  printf "\n"
}


answer_is_yes() {
  [[ "$REPLY" =~ ^[Yy]$ ]] && return 0 || return 1
}


print_in_red() {
  printf "\033[31m$1\033[m"
}


print_in_green() {
  printf "\033[32m$1\033[m"
}


print_in_yellow() {
  printf "\033[33m$1\033[m"
}


print_in_blue() {
  printf "\033[34m$1\033[m"
}


spinstr='|/-\'
spinner() {
  local pid=$1
  local delay=0.1
  local size=$((${#2}+4))
  printf "   "
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    print_in_yellow "[${spinstr:0:1}] ${2}"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    eval printf '\\b%.0s' {1..$size}
  done
}


print_heading() {
  print_in_blue "\n • ${1}\n"
}


print_subheading() {
  print_in_blue "\n   ${1}\n\n"
}


execute() {
  eval $1 > /dev/null 2>&1 &
  spinner $! "${2}"
  wait %1
  if [ $? -eq 0 ]; then
    print_in_green "[✔] ${2}\n"
    return 0
  else
    print_in_red "[✖] ${2}\n"
    return 1
  fi
}


install_package() {
  execute "sudo apt -y install ${2}" "${1}"
}


install_pip_package() {
  execute "pip install --user ${2}" "${1}"
}


install_pip3_package() {
  execute "pip3 install --user ${2}" "${1}"
}


symlink() {
  execute "ln -fs '${PARENTDIR}/${1}' '${HOME}/${2}'" "${1} →  ~/${2}"
}


install_oh_my_zsh() {
  if [ ! -n "$ZSH" ]; then 
    ZSH=~/.oh-my-zsh 
  fi
  if [ -d "$ZSH" ]; then
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
