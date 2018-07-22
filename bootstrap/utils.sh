#!/usr/bin/env bash
#
# Utility functions for the bootstrap script.

# The loading spinner characters to cycle
spinstr="|/-\\"

# ASCII colors
reset=$(  tput sgr0    2>/dev/null)
red=$(    tput setaf 1 2>/dev/null)
green=$(  tput setaf 2 2>/dev/null)
yellow=$( tput setaf 3 2>/dev/null)
blue=$(   tput setaf 4 2>/dev/null)
magenta=$(tput setaf 5 2>/dev/null)
cyan=$(   tput setaf 6 2>/dev/null)


newline() {
  printf "\\n"
}


heading() {
  printf "\\n%s • %s%s\\n" "$blue" "$1" "$reset"
}


subheading() {
  printf "\\n%s   %s%s\\n\\n" "$blue" "$1" "$reset"
}


info() {
  printf "\\n%s   [i] %s%s\\n" "$cyan" "$1" "$reset"
}


warning() {
  printf "\\n%s   [!] %s%s\\n" "$magenta" "$1" "$reset"
}


error() {
  printf "\\n%s   [✖] %s%s\\n" "$red" "$1" "$reset"
}


# Prompt the user with a yes or no question. Times out defaulting to 'No' after 10 seconds.
#
# Arguments:
#   $1 the prompt text
#
# Returns:
#   0 if the result was yes
#   1 if the result was no or timed out
ask_for_confirmation() {
  unset ANSWER
  printf "   %s[?] %s (y/N) %s" "$yellow" "$1" "$reset"
  read -r -n 1 -t 10 ANSWER
  printf "\\n"
  [[ "$ANSWER" =~ ^[Yy]$ ]] && return 0 || return 1
}


# Check if the given command exists.
#
# Arguments:
#   $1 the command
#
# Returns:
#   0 if the the command exists
#   1 if the command does not exist
command_exists() {
  command -v "$1" &> /dev/null && return 0 || return 1
}


# Checks if the current operating system is equal to the given one.
#
# Arguments:
#   $1 the platform name
#
# Returns:
#   0 if the platform is the same
#   1 if the platform is not the same
os_is() {
  if [ -z "$PLATFORM" ]; then
    PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
  fi
  [ "$PLATFORM" == "$1" ] && return 0 || return 1
}


# Creates the given directory.
#
# Arguments:
#   $1 the directory to create
create_directory() {
  if [ ! -d "$1" ]; then
    execute "mkdir -p '$1'" "Create directory ${1/#$HOME/~}"
  fi
}


# Removes the given directory.
#
# Arguments:
#   $1 the directory to remove
remove_directory() {
  execute "rm -rf $1" "Remove directory ${1/#$HOME/~}"
}


# Request root privileges and background a process to reset the timer.
#
# Returns:
#   0 if we have sudo access
#   1 if there was an error
ask_for_sudo() {
  if (( EUID != 0 )) && [ -z "$SUDO_REQUESTED" ]; then
    # Check if we do not already have root privileges
    if ! sudo -n -v &> /dev/null; then
      subheading "Root privileges are required to continue"
      sudo -v &> /dev/null || return 1
    fi
    # Background a process to reset the root privilege timer until this script has ended
    while true; do sudo -n true; sleep 10; kill -0 "$$" || exit; done 2>/dev/null &
    # So we can call this function multiple times in a script and do not spawn many processes
    SUDO_REQUESTED=true
  fi

  return 0
}


# Prompt the user with a list of choices. Loops forever until an option is chosen. The result will
# be stored in CHOICE.
#
# Arguments:
#   $1 the prompt description
#   $x each option as an argument
#
# Returns:
#   0 if the user chose one of the options
#   1 if the user chose to exit
prompt_for_choice() {
  local prompt=$1
  shift
  printf "\\n%s   [?] %s%s\\n" "$yellow" "$prompt" "$reset"

  local index=1
  for choice in "$@"; do
    printf "%s       %d) %s%s\\n" "$yellow" "$index" "$choice" "$reset"
    index=$((index+1))
  done
  printf "%s       x) exit%s\\n" "$yellow" "$reset"

  while : ; do
    printf "       "
    read -r -n 1 ICHOICE
    if [ "$ICHOICE" == "x" ]; then
      printf "\\n"
      return 1
    elif [ ! -z "${!ICHOICE}" ] && (( ICHOICE != 0 )); then
      export CHOICE="${!ICHOICE}"
      printf "\\n"
      return 0
    fi
    printf " is an invalid selection\\n"
  done
}


# Creates a spinner that spins until the given PID no longer exists.
#
# Arguments:
#   $1 the PID
#   $2 the text to display while spinning
spinner() {
  local pid=$1
  local text=$2
  local length=$((${#text}+4))

  tput civis -- invisible
  printf "   "
  while ps -p "$pid" > /dev/null 2>&1; do
    local temp=${spinstr:0:1}
    spinstr=${spinstr:1}$temp
    printf "%s[%s] %s%s" "$yellow" "$temp" "$text" "$reset"
    sleep 0.075
    eval printf '\\b%.0s' "{1..$length}"
  done
  tput cnorm -- normal
}


# Abort the script, reset the cursor to display on, and kill the given PID.
#
# Arguments:
#   $1 the PID
#   $2 the text describing the PID
abort() {
  local pid=$1
  local text=$2

  tput cnorm -- normal
  if kill -s HUP "$1" 2>&1; then
    warning "$text killed"
  fi
  error "Aborted!"
  printf "\\n"
  exit 1
}


# Execute a command, display a loading spinner until the command is completed.
#
# Arguments:
#   $1 the command to execute
#   $2 the text to display while executing
#
# Returns:
#   0 if the command executed cleanly
#   1 if the command executed with an error
execute() {
  local cmd=$1
  local text=$2
  eval "$cmd" > /dev/null 2>&1 &
  local pid=$!

  trap 'abort $pid "$text"' SIGINT
  spinner "$pid" "$text"

  if wait $pid; then
    printf "%s[✔] %s%s\\n" "$green" "$text" "$reset"
    return 0
  else
    printf "%s[✖] %s%s\\n" "$red" "$text" "$reset"
    return 1
  fi
}


# Download the given file.
#
# Arguments:
#   $1 the url of the file to download
#   $2 the output file
#
# Returns:
#   0 if the file was downloaded
#   1 if the download failed or `curl` or `wget` commands does not exist
download() {
  local url=$1
  local output=$2

  if command_exists curl; then
    curl -LsSo "$output" "$url" &> /dev/null && return 0 || return 1
  elif command_exists wget; then
    wget -qO "$output" "$url" &> /dev/null && return 0 || return 1
  else
    return 1
  fi
}
