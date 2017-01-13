#!/usr/bin/env bash

GITHUB_REPOSITORY="rossmacarthur/dotfiles"
DOTFILES_ORIGIN="git@github.com:${GITHUB_REPOSITORY}.git"
DOTFILES_TARBALL_URL="https://github.com/${GITHUB_REPOSITORY}/tarball/master"
DOTFILES_UTILS_URL="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/master/bootstrap/utils.sh"
DOTFILES_DIRECTORY="${HOME}/.dotfiles"


download() {
  local url=$1
  local output=$2
  if hash curl > /dev/null 2>&1; then
    curl -LsSo "${output}" "${url}" &> /dev/null
  elif hash wget > /dev/null 2>&1; then
    wget -qO "${output}" "${url}" &> /dev/null
  else
    printf "Please install curl or wget"
    return 1
  fi
  return 0  
}


download_utils() {
  local output=$(mktemp /tmp/XXXXX)
  download $DOTFILES_UTILS_URL $output
  . $output
  rm -rf $output
  return 0
}


download_archive() {
  if command_exists git; then
    execute "env git clone ${DOTFILES_ORIGIN} ${DOTFILES_DIRECTORY}" "Clone repository from GitHub"
    return $?
  elif command_exists tar && command_exists gzip; then
    local url=${DOTFILES_TARBALL_URL}
    local output=$(mktemp /tmp/XXXXX)
    execute "eval download ${url} ${output}" "Download archive from GitHub"
    execute "mkdir -p ${DOTFILES_DIRECTORY}" "Create directory ${DOTFILES_DIRECTORY}"
    execute "tar -zxf ${output} --strip-components 1 -C ${DOTFILES_DIRECTORY}" "Extract archive"
    return $?
  fi
  print_in_red "   [✖] Need git or tar to get archive\n"
  return 1
}


main() {
  if [ -f "utils.sh" ]; then
    . utils.sh
  else
    download_utils || return 1
  fi

  ask_for_sudo

  heading "Download and extract archive\n"
  if [ -d "${DOTFILES_DIRECTORY}" ]; then
    ask_for_confirmation "Installation detected in ${DOTFILES_DIRECTORY}. Overwrite?"
    if answer_is_yes; then
      execute "rm -rf ${DOTFILES_DIRECTORY}" "Remove folder ${DOTFILES_DIRECTORY}"
      download_archive || return 1
    fi
  else
    download_archive || return 1
  fi

  cd ${DOTFILES_DIRECTORY}/bootstrap

  if [ ! $1 ]; then
    ./bootstrap_device.sh
  else
    ./bootstrap_$1.sh
  fi

  heading "Complete!\n"
}


main $@ || printf "\033[31m\n • Aborted!\033[m\n"
