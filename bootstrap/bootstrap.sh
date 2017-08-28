#!/usr/bin/env bash

GITHUB_REPOSITORY="rossmacarthur/dotfiles"
GIT_BRANCH="master"
DOTFILES_TARBALL_URL="https://github.com/${GITHUB_REPOSITORY}/tarball/${GIT_BRANCH}"
DOTFILES_UTILS_URL="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/${GIT_BRANCH}/bootstrap/utils.sh"
DOTFILES_DIRECTORY="${HOME}/.dotfiles"


download_utils() {
  local output=$(mktemp /tmp/XXXXX)
  if hash curl > /dev/null 2>&1; then
    curl -LsSo "${output}" "${DOTFILES_UTILS_URL}" &> /dev/null
  elif hash wget > /dev/null 2>&1; then
    wget -qO "${output}" "${DOTFILES_UTILS_URL}" &> /dev/null
  else
    printf "Please install curl or wget"
    return 1
  fi
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
  local options=$(find . -type f -name "bootstrap_*.sh" | cut -d '_' -f 2- | cut -d '.' -f 1 | xargs -n20 | sort)
  prompt_for_choice $options "Please select a bootstrap type"
  [ $? -ne 0 ] && return 1
  ./bootstrap_$CHOICE.sh
  heading "Complete!\n"
}


main $@ || printf "\033[31m\n • Aborted!\033[m\n\n"
