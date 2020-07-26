#!/usr/bin/env bash

BOOTSTRAP_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$BOOTSTRAP_DIRECTORY" || exit 1
source utils.sh

usage() {
    cat 1>&2 <<EOF
Run the dotfiles bootstrap script.

Usage:
    bootstrap.sh [OPTIONS]

Options:
  -h, --help              Show this message and exit.
  -b, --bootstrap <NAME>  Specify the bootstrap script to run.
      --only <SECTION>    Specify a section to run (can be supplied multiple times).
      --skip <SECTION>    Specify a section to exclude (can be supplied multiple times).
EOF
}

main() {
  export BOOTSTRAP_OPTIONS
  export BOOTSTRAP_CHOICE
  export BOOTSTRAP_SECTION_FILTER=()
  export BOOTSTRAP_SECTION_EXCLUDE=()

  while test $# -gt 0
  do
    case $1 in
      -b|--bootstrap)
        shift
        if [ -z "$1" ]; then
          printf "Error: --bootstrap option requires an argument\n\n"
          usage
          exit 1
        fi
        BOOTSTRAP_CHOICE="$1"
        ;;
      --only)
        shift
        if [ -z "$1" ]; then
          printf "Error: --only option requires an argument\n\n"
          usage
          exit 1
        fi
        BOOTSTRAP_SECTION_FILTER+=("$1")
        ;;
      --skip)
        shift
        if [ -z "$1" ]; then
          printf "Error: --skip option requires an argument\n\n"
          usage
          exit 1
        fi
        BOOTSTRAP_SECTION_EXCLUDE+=("$1")
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf "Error: unrecognized command line argument '%s'\n\n" "$1"
        usage
        exit 1
        ;;
    esac
    shift
  done

  # Find the list of bootstraps scripts in the current folder
  BOOTSTRAP_OPTIONS=()
  for filename in bootstrap_*.sh; do
    filename="${filename#bootstrap_}"
    filename="${filename%.*}"
    BOOTSTRAP_OPTIONS+=("$filename")
  done

  # If --bootstrap wasn't passed in
  if [ -z "$BOOTSTRAP_CHOICE" ]; then
    prompt_choice "Please select a bootstrap type" "${BOOTSTRAP_OPTIONS[@]}" || abort
    BOOTSTRAP_CHOICE=$USER_CHOICE
  # Otherwise check if the given --bootstrap value is a valid choice
  elif ! contains "BOOTSTRAP_OPTIONS" "$BOOTSTRAP_CHOICE"; then
    printf "Error: unrecognized bootstrap type '%s'\n\n" "$BOOTSTRAP_CHOICE"
    printf "The choices are: %s\n" "${BOOTSTRAP_OPTIONS[*]}"
    exit 1
  fi

  # Run the bootstrap script
  # shellcheck disable=SC1090
  source "bootstrap_$BOOTSTRAP_CHOICE.sh"

  if [ -n "$DOTFILES_RETURNCODE" ]; then
    heading --after 2 "There were failures 💔 😢 💔"
    exit 1
  fi
  heading --after 2 "Complete! ✨ 🍰 ✨"
}

main "$@"
