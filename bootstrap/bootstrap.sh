#!/usr/bin/env bash

BOOTSTRAP_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIRECTORY="$(dirname "$BOOTSTRAP_DIRECTORY")"

cd "$BOOTSTRAP_DIRECTORY" || exit 1
source utils.sh

usage() {
    cat 1>&2 <<EOF
Run the dotfiles bootstrap script.

Usage:
    bootstrap.sh [OPTIONS]

Options:
  -h, --help                Show this message and exit.
  -b, --bootstrap <NAME>    Specify the bootstrap script to run.
  -f, --filter <SECTION>    Specify a section to run (multiple are allowed).
  -x, --exclude <SECTION>   Specify a section to skip (multiple are allowed).
EOF
}

main() {
  export BOOTSTRAP_OPTIONS
  export BOOTSTRAP_CHOICE
  export BOOTSTRAP_FILTER=()
  export BOOTSTRAP_EXCLUDE=()

  while test $# -gt 0; do
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
      -f|--filter)
        shift
        if [ -z "$1" ]; then
          printf "Error: --filter option requires an argument\n\n"
          usage
          exit 1
        fi
        BOOTSTRAP_FILTER+=("$1")
        ;;
      -x|--exclude)
        shift
        if [ -z "$1" ]; then
          printf "Error: --exclude option requires an argument\n\n"
          usage
          exit 1
        fi
        BOOTSTRAP_EXCLUDE+=("$1")
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
  source bootstrap_$BOOTSTRAP_CHOICE.sh

  heading --after 2 "Complete! ✨ 🍰 ✨"
}

main "$@"
