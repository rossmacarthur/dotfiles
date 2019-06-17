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
#   $1 the platform name
#
# Returns:
#   0 if the platform is the same
#   1 if the platform is not the same
os_is() {
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
#   -c, --color   the color (none, red, green, yellow, blue, magenta, cyan)
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
#   1 if invalid options or extra arguments were given
#   0 the print was successful
print() {
  local color="none"
  local indent=INDENT
  local prefix
  local suffix
  local before=0
  local after=1
  local reset=$(tput sgr0 2>/dev/null)
  local rest=()

  while [ -n "$1" ]
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
  print --indent 0 "$@"
}

# Print a heading.
heading() {
  print --color blue --before 1 --indent "$(( INDENT-2 ))" --prefix "• " "$@"
}

# Print a subheading.
subheading() {
  print --color blue --before 1 --after 2 "$@"
}

# Print an info message.
info() {
  print --color cyan --prefix "[i] " "$@"
}

# Print an warning message.
warning() {
  print --color magenta --prefix "[!] " "$@"
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

# Prompt the user with a list of choices. Loops forever until a valid option is chosen. The result
# will be stored in USER_CHOICE.
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
    elif [ ! -z "${!ichoice}" ] && (( ichoice!=0 ))
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
# Warning: this function backgrounds a process to reset the sudo timer. Since sudo accesses
# /dev/tty you might not be able to use something like read while this is running.
# See https://unix.stackexchange.com/a/499433/278207.
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

# Prompt the user with a yes or no question. Times out defaulting to 'No' after 10 seconds.
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

# Execute a command and display a loading spinner until the command is completed.
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

  # Actually start running the command
  eval "$cmd" >/dev/null 2>&1 &
  local pid=$!

  # Setup a spinner to display while the command is running.
  trap 'aborter $pid "$text"' SIGINT
  spinner "$pid" "$text"
  # If the command executed with 0.
  if wait $pid
  then
    success --indent 0 "$text"
  else
    error --indent 0 "$text"
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

  if exists curl
  then
    execute "curl -LsSo '$output' '$url'" "Download $url"
  elif exists wget
  then
    execute "wget -qO '$output' '$url'" "Download $url"
  else
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
  create_directory "$(dirname "$HOME/$2")"
  execute "ln -fs '$DOTFILES_DIRECTORY/$1' '$HOME/$2'" "$1 → ~/$2"
  sleep 0.1
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

# Sync an entire directory to another.
#
# Arguments:
#   $1 the directory source relative to the dotfiles directory
#   $2 the directory source relative to the $HOME directory
sync_directory() {
  create_directory "$(dirname "$HOME/$2")"
  execute "rsync '$DOTFILES_DIRECTORY/$1' '$HOME/$2'" "$1 → ~/$2"
  sleep 0.1
}


# Update the system package manager.
#
# This is a `brew update` on macOS and a `sudo apt update` otherwise.
if os_is "darwin"
then
  update_package_manager() {
    if ! exists brew
    then
      execute \
        "echo | ruby -e '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)'" \
        "Homebrew (install)"
    fi
    execute "brew update" "Homebrew (update)"
  }
else
  update_package_manager() {
    execute "sudo apt update" "APT (update)"
    execute "sudo apt -y upgrade" "APT (upgrade)"
    execute "sudo apt -y dist-upgrade" "APT (dist-upgrade)"
    execute "sudo apt -y autoremove" "APT (autoremove)"
  }
fi

# Install a package using the system package manager.
if os_is "darwin"
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

# Clone a git repository to the given location.
clone_git_repository() {
  local name=$1
  local url=$2
  local directory=$3

  if check_directory "$directory" "$name is already installed. Reinstall?"
  then
    execute "git clone --depth=1 $url $directory" "Clone $name"
  fi
}

clone_vim_flake8_plugin() {
  clone_git_repository \
    "Vim Flake8" \
    "https://github.com/nvie/vim-flake8.git" \
    "$HOME/.vim/bundle/flake8"
}

clone_vim_base16_themes() {
  clone_git_repository \
    "Vim Base16" \
    "https://github.com/chriskempson/base16-vim.git" \
    "$HOME/.vim/colors/base16"
  execute \
    "cp $HOME/.vim/colors/base16/colors/*.vim $HOME/.vim/colors/" \
    "Copy Base16 color schemes to ~/.vim/colors/"
}

install_pip() {
  if exists pip; then
    execute "pip install --upgrade pip" "PIP"
  else
    execute "curl -LsSo get-pip.py https://bootstrap.pypa.io/get-pip.py" "Download get-pip.py"
    execute "sudo python get-pip.py" "PIP"
    rm -f get-pip.py
  fi
}

install_pip_package() {
  local msg=${2:-$1}
  execute "pip install --upgrade $1" "$msg"
}

install_pyenv() {
  if check_directory "$HOME/.pyenv" "pyenv is already installed. Reinstall?"
  then
    execute "curl https://pyenv.run | bash" "Install pyenv and friends"
  fi

  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.zprofile
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $HOME/.zprofile

  symlink "pyenv/pyenv-virtualenv-after.bash" ".pyenv/plugins/pyenv-virtualenv/etc/pyenv.d/virtualenv/after.bash"
}

install_pyenv_python2() {
  local version=$($HOME/.pyenv/bin/pyenv install --list | grep '^\s\+2.7' | tail -1 | xargs)
  execute "$HOME/.pyenv/bin/pyenv install --skip-existing $version" "Python $version"
}

install_pyenv_python3() {
  local version=$($HOME/.pyenv/bin/pyenv install --list | grep '^\s\+3.7' | tail -1 | xargs)
  execute "$HOME/.pyenv/bin/pyenv install --skip-existing $version" "Python $version"
}

create_pyenv_virtualenv() {
  if [ -f "$HOME/.pyenv/versions/global" ] && ! confirm "Global virtualenv already exists. Reinstall?"
  then
    return
  fi

  local version=$($HOME/.pyenv/bin/pyenv install --list | grep '^\s\+3.7' | tail -1 | xargs)
  execute \
    "$HOME/.pyenv/bin/pyenv virtualenv --force $version global && $HOME/.pyenv/bin/pyenv global global" \
    "Global virtualenv"
}

install_python_package() {
  local msg=${2:-$1}
  execute "PYENV_VERSION=global $HOME/.pyenv/bin/pyenv exec pip install --upgrade $1" "$msg"
}

install_rustup() {
  execute "curl https://sh.rustup.rs -sSf | bash -s - -y" "Rustup"
}

install_rustup_component() {
  local msg=${2:-$1}
  execute "$HOME/.cargo/bin/rustup component add $1" "$msg"
}

install_cargo_package() {
  local msg=${2:-$1}

  if ! "$HOME/.cargo/bin/cargo" install --list | grep "$1" >/dev/null 2>&1
  then
    execute "$HOME/.cargo/bin/cargo install --force $1" "$msg"
  fi
}
