#!/usr/bin/env bash

BOOTSTRAP_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BOOTSTRAP_DIRECTORY" || exit 1
source utils.sh


main() {
  # Get root privileges from the user
  ask_for_sudo || return 1

  # Find the list of bootstraps scripts in the current folder
  options=()
  for filename in bootstrap_*.sh; do
    filename="${filename#bootstrap_}"
    filename="${filename%.*}"
    options+=("$filename")
  done

  # Prompt the user to select a bootstrap type
  prompt_for_choice "Please select a bootstrap type" "${options[@]}" || return 1

  # Run the bootstrap script
  source bootstrap_$CHOICE.sh

  heading "Complete!"
  printf "\\n"
}


main "$@" || { error "Aborted!" && printf "\\n" && exit 1; }
