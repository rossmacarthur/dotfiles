#!/usr/bin/env bash

GITHUB_USERNAME="rossmacarthur"
GITHUB_REPOSITORY="dotfiles"
GIT_BRANCH="master"
DOTFILES_TARBALL_URL="https://github.com/$GITHUB_USERNAME/$GITHUB_REPOSITORY/tarball/$GIT_BRANCH"
DOTFILES_UTILS_URL="https://raw.githubusercontent.com/$GITHUB_USERNAME/$GITHUB_REPOSITORY/$GIT_BRANCH/bootstrap/utils.sh"
DOTFILES_DIRECTORY="$HOME/.dotfiles"

# ASCII colors
reset=$(  tput sgr0    2>/dev/null)
red=$(    tput setaf 1 2>/dev/null)


error() {
  printf "\\n%s   [✖] %s%s\\n" "$red" "$1" "$reset"
}


# Download utils.sh.
#
# Returns:
#   0 if utils.sh was downloaded
#   1 if the download failed or `curl` or `wget` commands does not exist
download_utils() {
  local url=$DOTFILES_UTILS_URL
  local output=$(mktemp)

  if command -v curl &> /dev/null; then
    curl -LsSo "$output" "$url" &> /dev/null
  elif command -v wget &> /dev/null; then
    wget -qO "$output" "$url" &> /dev/null
  else
    error "Please install curl or wget"
    return 1
  fi

  (( $? != 0 )) && error "Unable to download utils" && return 1
  source "$output"
  rm -f "$output"

  return 0
}


# Download the dotfiles tarball.
#
# Returns:
#   0 if the archive was downloaded
#   1 if the download failed
download_archive() {
  local url=$DOTFILES_TARBALL_URL
  local output=$(mktemp)

  if command_exists tar; then
    execute "download $url $output" "Download archive"
    create_directory "$DOTFILES_DIRECTORY"
    execute "tar -zxf $output --strip-components 1 -C $DOTFILES_DIRECTORY" "Extract archive"
    return $?
  else
    print_error "Need tar to extract archive"
    return 1
  fi
}


main() {
  # Download and source utils.sh so that we have all utility functions
  download_utils || return 1

  # Get root privileges from the user
  ask_for_sudo || return 1

  heading "Download and extract archive"
  printf "\\n"

    # Get the dotfiles as a tarball from GitHub
  if [ -d "$DOTFILES_DIRECTORY" ]; then
    if ask_for_confirmation "Installation detected in ${DOTFILES_DIRECTORY/#$HOME/~}. Delete?"; then
      remove_directory "$DOTFILES_DIRECTORY"
      download_archive || return 1
    fi
  else
    download_archive || return 1
  fi

  # Run the bootstrap script
  cd "$DOTFILES_DIRECTORY/bootstrap" || return 1
  source bootstrap.sh
}


main "$@" || { error "Aborted!" && printf "\\n" && exit 1; }
