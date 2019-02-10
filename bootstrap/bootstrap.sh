#!/usr/bin/env bash

BOOTSTRAP_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BOOTSTRAP_DIRECTORY" || exit 1
source utils.sh

main() {
  # Find the list of bootstraps scripts in the current folder
  options=()
  for filename in bootstrap_*.sh; do
    filename="${filename#bootstrap_}"
    filename="${filename%.*}"
    options+=("$filename")
  done

  # Prompt the user to select a bootstrap type
  prompt_choice "Please select a bootstrap type" "${options[@]}" || abort

  # Run the bootstrap script
  source bootstrap_$USER_CHOICE.sh

  heading --after 2 "Complete! ✨ 🍰 ✨"
}

main "$@"
