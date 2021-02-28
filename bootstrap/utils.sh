#!/usr/bin/env bash
#
# Utility functions for the dotfiles bootstrap script.

# The amount to indent all messages.
INDENT=${INDENT:-3}

# Check if the given command exists.
#
# Arguments:
#   $1 the command
#
# Returns:
#   0 if the the command exists
#   1 if the command does not exist
exists() {
  command -v "$@" >/dev/null 2>&1
}

# Check if the current operating system is equal to the given one.
#
# Arguments:
#   $1 the platform name, e.g. "darwin", "linux"
#
# Returns:
#   0 if the platform is the same
#   1 if the platform is not the same
is_platform() {
  if [ -z "$PLATFORM" ]
  then
    PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
  fi
  [ "$PLATFORM" == "$1" ]
}

# Print the given string the given amount of times.
#
# Arguments:
#   $1 the string to print
#   $2 the number of times to print the string
repeat() {
  local str=$1
  local count=${2:-0}
  for ((i=0; i<count; i++))
  do
    printf "%s" "$str"
  done
}

# A custom print function.
#
# Options:
#   -c, --color   the color (none, red, green, yellow, blue, magenta, cyan, grey)
#   -i, --indent  the indent count (default: $INDENT)
#   -p, --prefix  text to prefix the primary text
#   -s, --suffix  text to suffix the primary text
#   -b, --before  the new line before count (default: 0)
#   -a, --after   the new line after count (default: 1)
#
# Examples:
#   $ print -c blue -i 0 "Text"
#   Text
#
# Returns:
#   0 the print was successful
#   1 if invalid options or extra arguments were given
print() {
  local color="none"
  local indent=INDENT
  local prefix
  local suffix
  local before=0
  local after=1
  local reset
  local rest=()

  reset=$(tput sgr0 2>/dev/null)

  while test $# -gt 0
  do
    case "$1" in
      -c|--color)
        color=$2
        shift
        ;;
      -i|--indent)
        indent=$2
        shift
        ;;
      -p|--prefix)
        prefix=$2
        shift
        ;;
      -s|--suffix)
        suffix=$2
        shift
        ;;
      -b|--before)
        before=$2
        shift
        ;;
      -a|--after)
        after=$2
        shift
        ;;
      *)
        rest+=("$1")
        ;;
    esac
    shift
  done

  case "$color" in
    none)
      color=$reset
      ;;
    red)
      color=$(tput setaf 1 2>/dev/null)
      ;;
    green)
      color=$(tput setaf 2 2>/dev/null)
      ;;
    yellow)
      color=$(tput setaf 3 2>/dev/null)
      ;;
    blue)
      color=$(tput setaf 4 2>/dev/null)
      ;;
    magenta)
      color=$(tput setaf 5 2>/dev/null)
      ;;
    cyan)
      color=$(tput setaf 6 2>/dev/null)
      ;;
    grey)
      color=$(tput setaf 8 2>/dev/null)
      ;;
    *)
      echo "print: invalid color -- $color"
      return 1
      ;;
  esac

  printf "%s" "$color"
  repeat $'\n' "$before"
  repeat " " "$indent"
  printf "%s%s%s" "$prefix" "${rest[*]}" "$suffix"
  repeat $'\n' "$after"
  printf "%s" "$reset"
}

# Print a newline.
newline() {
  print --indent 0
}

# Print a heading.
heading() {
  print --color blue --before 1 --indent "$(( INDENT-2 ))" --prefix "• " "$@"
}

# Print a subheading.
subheading() {
  print --color blue --before 1 --after 2 "$@"
}

# Print an success message.
success() {
  print --color green --prefix "[✔] " "$@"
}

# Print an error message.
error() {
  print --color red --prefix "[✖] " "$@"
  return 1
}

# Abort the current process.
#
# Arguments:
#   $1 the message to abort with
abort() {
  local msg=${1:-Aborted!}
  error --before 1 --after 2 "$msg"
  exit 1
}

# Check if an array contains a particular element.
#
# Arguments:
#   $1 the variable name of the global array to check
#   $2 the element to check for
contains() {
  local match=$2
  for e in "${!1}"
  do
    if [ "$e" == "$match" ]
    then
      return 0
    fi
  done
  return 1
}

# Whether or not a section is configured.
#
# Arguments:
#   $1 the section tag.
#
# Returns:
#   0 the section is configured
#   1 the section is not configured
is_section_configured() {
  { [ -z "${BOOTSTRAP_SECTION_FILTER[*]}" ] || contains "BOOTSTRAP_SECTION_FILTER" "$1"; } \
      && { [ -z "${BOOTSTRAP_SECTION_EXCLUDE[*]}" ] || ! contains "BOOTSTRAP_SECTION_EXCLUDE" "$1"; }
}

# Print a heading if it is configured.
#
# Arguments:
#   $1 the heading text
#   $2 the section tag that this heading corresponds to (defaults to $1)
#
# Returns:
#   0 the heading is configured
#   1 the heading is not configured
heading_if() {
  local text=$1
  local name=${2:-$1}
  local tag
  tag=$(echo "$name" | tr '[:upper:]' '[:lower:]')
  if is_section_configured "$tag"
  then
    heading "$text"
    return 0
  else
    heading "Skipped section: $1" --color grey
    return 1
  fi
}

# Prompt the user to enter data. The data will be stored in USER_ANSWER.
#
# Arguments:
#   $1 the prompt text
#
# Returns:
#   0 if the prompt succeeded
#   1 the read timed out
prompt() {
  unset USER_ANSWER
  print --color yellow --after 0 --prefix "[?] " --suffix " " "$@"
  read -r -t 10 USER_ANSWER || {
    newline
    return 1
  }
}

# Prompt the user with a list of choices. Loops forever until a valid option is
# chosen. The result will be stored in USER_CHOICE.
#
# Arguments:
#   $1 the prompt description
#   $x each option as an argument
#
# Returns:
#   0 if the user chose one of the options
#   1 if the user chose to exit
prompt_choice() {
  unset USER_CHOICE
  local ichoice
  local indent="    "
  local index=1

  # First print the prompt, and the list of choices with their indexes.
  print --color yellow --before 1 --prefix "[?] " "$1"
  shift
  for choice in "$@"
  do
    print --color yellow --prefix "$indent" "$index) $choice"
    index=$(( index+1 ))
  done
  print --color yellow --prefix "$indent" "x) exit"

  # Loop until the user inputs a valid choice.
  while true
  do
    print --after 0 --prefix "$indent"
    read -r -n 1 ichoice
    if [ "$ichoice" == "x" ]
    then
      newline
      return 1
    elif [ -n "$ichoice" ] && (( ichoice != 0 )) && [ -n "${!ichoice}" ]
    then
      export USER_CHOICE="${!ichoice}"
      newline
      return 0
    fi
    print --color red --indent 1 "is an invalid selection"
  done
}

# Request root privileges and background a process to reset the sudo timer.
#
# Warning: this function backgrounds a process to reset the sudo timer. Since
# sudo accesses /dev/tty you might not be able to use something like read while
# this is running. See https://unix.stackexchange.com/a/499433/278207.
#
# Returns:
#   0 if we have sudo access
#   1 if we don't have sudo access
request_sudo() {
  local password

  if (( EUID != 0 ))
  then
    # Check if we do not already have root privileges
    if ! sudo -n -v &> /dev/null
    then
      print --color blue --before 1 "Root privileges are required to continue."
      print --color blue --after 0 "Enter password: "
      trap 'stty echo && newline && abort' SIGINT
      read -r -s password
      trap - SIGINT
      newline
      echo "$password" | sudo -S -v >/dev/null 2>&1 || abort "Incorrect password."
    fi
    # Background a process to reset the root privilege timer until this script has ended
    {
      while true
      do
        sleep 10
        sudo -n true
        kill -0 "$$" || {
          sudo -k
          exit 0
        }
      done
    } >/dev/null 2>&1 &
  fi

  return 0
}

# Prompt the user with a yes or no question. Times out defaulting to 'No' after
# 10 seconds.
#
# Arguments:
#   $1 the prompt text
#
# Returns:
#   0 if the result was yes
#   1 if the result was no or timed out
confirm() {
  unset USER_ANSWER
  print --color yellow --after 0 --prefix "[?] " --suffix " (y/N) " "$@"
  read -r -n 1 -t 10 USER_ANSWER
  newline
  [[ "$USER_ANSWER" =~ ^[Yy]$ ]]
}

# Execute a command and display a loading spinner until the command is
# completed.
#
# Arguments:
#   $1 the command to execute
#   $2 the text to display while executing
#
# Returns:
#   0 if the command executed cleanly
#   1 if the command executed with an error
execute() {
  local spinstr="|/-\\"

  # Creates a spinner that spins until the given PID no longer exists.
  spinner() {
    local pid=$1
    local temp
    local text=$2
    local length=$(( ${#text}+4 ))

    tput civis -- invisible
    print --after 0
    while ps -p "$pid" >/dev/null 2>&1
    do
      temp=${spinstr:0:1}
      spinstr=${spinstr:1}$temp
      print --color yellow --after 0 --indent 0 --prefix "[$temp] " "$text"
      sleep 0.075
      repeat $'\b' "$length"
    done
    tput cnorm -- normal
  }

  # Abort the script, reset the cursor to display on, and kill the given PID.
  aborter() {
    local pid=$1
    local text=$2
    tput cnorm -- normal
    kill -s HUP "$1" >/dev/null 2>&1 && {
      print --color magenta --before 1 --prefix "[!] " "$text killed";
    }
    error --after 2 "Aborted!"
    exit 1
  }

  local cmd=$1
  local text=${2:-$1}
  local temp_file

  # Actually start running the command
  temp_file=$(mktemp)
  eval "$cmd" &>"$temp_file" &
  local pid=$!

  # Setup a spinner to display while the command is running.
  trap 'aborter $pid "$text"' SIGINT
  spinner "$pid" "$text"
  # If the command executed with 0.
  if wait "$pid"
  then
    success --indent 0 "$text"
    rm -f "$temp_file"
    return 0
  else
    error --indent 0 "$text"
    export DOTFILES_RETURNCODE=1
    # Print the command's output indented.
    print --color grey --indent 0 --after 2 "$(sed "s/^/$(repeat " " "$INDENT")/g" "$temp_file")"
    rm -f "$temp_file"
    return 1
  fi
}

# Creates the given directory.
#
# Arguments:
#   $1 the directory to create
create_directory() {
  if [ ! -d "$1" ]
  then
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

# Create a symlink between two files.
#
# Arguments:
#   $1 the file source relative to the dotfiles directory
#   $2 the file destination relative to the $HOME directory
symlink() {
  local src="$DOTFILES_DIRECTORY/src/$1"
  local dst="$HOME/$2"
  execute "_symlink '$src' '$dst'" "$1 → ~/$2"
}
_symlink() {
  local src=$1
  local dst=$2
  [ -f "$src" ] || { echo "Error: $src does not exist" >&2 && return 1; }
  create_directory "$(dirname "$dst")" || return 1
  ln -fs "$src" "$dst" || return 1
  sleep 0.05
}

# Symlink a Zsh plugin.
#
# Arguments:
#   $1 the file source relative to the dotfiles/zsh/plugins directory.
#   $2 the name of the plugin in the ~/.zsh/plugins directory.
symlink_zsh_plugin() {
  local name=${2:-$1}
  symlink "zsh/plugins/$1.plugin.zsh" ".zsh/plugins/$name.plugin.zsh"
}

# Update the system package manager.
#
# This is a `brew update` on macOS and a `sudo apt update` otherwise.
if is_platform "darwin"
then
  update_package_manager() {
    execute "brew update" "Homebrew (update)"
  }
else
  update_package_manager() {
    execute "sudo apt update" "APT (update)"
    execute "sudo apt -y upgrade" "APT (upgrade)"
    execute "sudo apt -y autoremove" "APT (autoremove)"
  }
fi

# Install a package using the system package manager.
if is_platform "darwin"
then
  install_package() {
    local msg=${2:-$1}
    execute "brew install $1 || brew upgrade $1" "$msg"
  }
else
  install_package() {
    local msg=${2:-$1}
    execute "sudo apt -y install $1" "$msg"
  }
fi

# Install multiple packages using the system package manager.
install_packages() {
  for package in "$@"
  do
    install_package "$package"
  done
}

# Check whether a directory exists, and prompt user as to whether we can remove
# it.
check_directory() {
  local directory=$1
  local prompt=$2

  if [ -d "$directory" ]
  then
    if confirm "$prompt"
    then
      remove_directory "$directory"
      return 0
    fi
  else
    return 0
  fi

  return 1
}

install_sheldon() {
  if exists sheldon && ! confirm "Sheldon is already downloaded. Reinstall?"
  then
    return
  fi

  if exists cargo
  then
    execute "cargo install sheldon" "Sheldon"
  else
    execute "curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | \
             bash -s -- --repo 'rossmacarthur/sheldon' --to $HOME/.local/bin" "Sheldon"
  fi
}

install_pyenv() {
  if check_directory "$HOME/.pyenv" "pyenv is already installed. Reinstall?"
  then
    execute "curl https://pyenv.run | bash" "Install pyenv and friends"
  fi
  symlink "pyenv/pyenv-virtualenv-after.bash" ".pyenv/plugins/pyenv-virtualenv/etc/pyenv.d/virtualenv/after.bash"
}

install_pyenv_python3() {
  local version
  version=$("$HOME/.pyenv/bin/pyenv" install --list | grep '^\s\+3.9.\d' | tail -1 | xargs)
  execute "$HOME/.pyenv/bin/pyenv install --skip-existing $version" "Python $version"
}

create_pyenv_virtualenv() {
  local version
  if [ -f "$HOME/.pyenv/versions/global" ] && ! confirm "Global virtualenv already exists. Reinstall?"
  then
    return
  fi
  version=$("$HOME/.pyenv/bin/pyenv" install --list | grep '^\s\+3.9.\d' | tail -1 | xargs)
  execute \
    "$HOME/.pyenv/bin/pyenv virtualenv --force $version global && $HOME/.pyenv/bin/pyenv global global" \
    "Global virtualenv"
}

install_python_package() {
  local msg=${2:-$1}
  execute "PYENV_VERSION=global $HOME/.pyenv/bin/pyenv exec pip install --upgrade $1" "$msg"
}

install_rustup() {
  execute "curl https://sh.rustup.rs -sSf | bash -s - -y --no-modify-path" "Rustup"
}

install_rust_version() {
  local toolchain=$1
  execute "$HOME/.cargo/bin/rustup update $toolchain" "Rust ($toolchain)"
}

install_cargo_package() {
  local msg=${2:-$1}
  execute "$HOME/.cargo/bin/cargo install $1" "$msg"
}

install_launch_agent() {
  local label=${2:-$1}
  local src="launchd/$1.plist"
  local dst="Library/LaunchAgents/$label.plist"
  execute "_install_launch_agent" "Load $src → $dst"
}
_install_launch_agent() {
  symlink "$src" "$dst" || return 1
  launchctl unload "$HOME/$dst" &>/dev/null
  launchctl load "$HOME/$dst" || return 1
}
