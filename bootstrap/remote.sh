#!/usr/bin/env bash

GITHUB_USERNAME="rossmacarthur"
GITHUB_REPOSITORY="dotfiles"
GIT_BRANCH="master"
DOTFILES_TARBALL_URL="https://github.com/${GITHUB_USERNAME}/${GITHUB_REPOSITORY}/tarball/${GIT_BRANCH}"
DOTFILES_UTILS_URL="https://raw.githubusercontent.com/${GITHUB_USERNAME}/${GITHUB_REPOSITORY}/${GIT_BRANCH}/bootstrap/utils.sh"
DOTFILES_DIRECTORY="${HOME}/.dotfiles"


print_error() {
  printf "\n\033[31m • ${1}\033[m\n"
}


download_utils() {
  local output=$(mktemp /tmp/XXXXX)
  if hash curl > /dev/null 2>&1; then
    curl -LsSo "${output}" "${DOTFILES_UTILS_URL}" &> /dev/null
  elif hash wget > /dev/null 2>&1; then
    wget -qO "${output}" "${DOTFILES_UTILS_URL}" &> /dev/null
  else
    print_error "Please install curl or wget"
    return 1
  fi
  [ $? -ne 0 ] && print_error "Unable to download utils" && return 1
  . $output
  rm -rf $output
  return 0
}


download_archive() {
  if command_exists tar; then
    local url=${DOTFILES_TARBALL_URL}
    local output=$(mktemp /tmp/XXXXX)
    execute "eval download ${url} ${output}" "Download archive from GitHub"
    create_directory "${DOTFILES_DIRECTORY}"
    execute "tar -zxf ${output} --strip-components 1 -C ${DOTFILES_DIRECTORY}" "Extract archive"
    return $?
  fi
  print_error "Need tar to extract archive"
  return 1
}


main() {
  download_utils || return 1

  ask_for_sudo

  heading "Download and extract archive\n"
  if [ -d "${DOTFILES_DIRECTORY}" ]; then
    ask_for_confirmation "Installation detected in ${DOTFILES_DIRECTORY/#$HOME/~}. Delete?"
    if answer_is_yes; then
      remove_directory "${DOTFILES_DIRECTORY}"
      download_archive || return 1
    fi
  else
    download_archive || return 1
  fi

  cd ${DOTFILES_DIRECTORY}/bootstrap
  ./bootstrap.sh
}

main $@ || print_error "Aborted!\n"
