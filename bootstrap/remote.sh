#!/usr/bin/env bash

# Global variables for the duration of this script.
DOTFILES_GITHUB_USERNAME=${DOTFILES_GITHUB_USERNAME:=rossmacarthur}
DOTFILES_GITHUB_REPOSITORY=${DOTFILES_GITHUB_REPOSITORY:=dotfiles}
DOTFILES_GIT_BRANCH=${DOTFILES_GIT_BRANCH:=master}
DOTFILES_TARBALL_URL="https://github.com/$DOTFILES_GITHUB_USERNAME/$DOTFILES_GITHUB_REPOSITORY/tarball/$DOTFILES_GIT_BRANCH"
DOTFILES_UTILS_URL="https://raw.githubusercontent.com/$DOTFILES_GITHUB_USERNAME/$DOTFILES_GITHUB_REPOSITORY/$DOTFILES_GIT_BRANCH/bootstrap/utils.sh"
DOTFILES_DIRECTORY=${DOTFILES_DIRECTORY:="$HOME/.dotfiles"}

# Print out an error message.
error() {
  local red=$(tput setaf 1 2>/dev/null)
  local reset=$(tput sgr0 2>/dev/null)
  printf "\\n%s%s[✖] %s%s\\n" "$red" "$INDENT" "$1" "$reset"
  return 1
}

# Download utils.sh.
#
# Returns:
#   0 if utils.sh was downloaded
#   1 if the download failed
download_utils() {
  local url=$DOTFILES_UTILS_URL
  local output=$(mktemp)

  if command -v curl >/dev/null 2>&1; then
    curl -LsSo "$output" "$url" >/dev/null 2>&1
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$output" "$url" >/dev/null 2>&1
  else
    error "Error: 'curl' or 'wget' is required"
    return 1
  fi

  (( $? != 0 )) && error "Error: failed to download utils.sh" && return 1
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

  if exists tar
  then
    execute "download $url $output" "Download archive"
    create_directory "$DOTFILES_DIRECTORY"
    execute "tar -zxf $output --strip-components 1 -C $DOTFILES_DIRECTORY" "Extract archive"
  else
    error "Error: 'tar' is required to extract archive"
  fi
}


main() {
  # Download and source utils.sh so that we have all utility functions
  download_utils || return 1

  # Get the dotfiles as a tarball from GitHub
  heading --after 2 "Download and extract archive"
  if [ -d "$DOTFILES_DIRECTORY" ]
  then
    if confirm "Installation detected in ${DOTFILES_DIRECTORY/#$HOME/~}. Delete?"
    then
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


main "$@" || {
  error "Aborted!"
  printf "\\n"
  exit 1
}
