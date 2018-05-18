#!/usr/bin/env bash

BOOTSTRAP_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ${BOOTSTRAP_DIRECTORY}

. utils.sh


main() {
  ask_for_sudo || return 1

  local options=$(find . -type f -name "bootstrap_*.sh" | cut -d '_' -f 2- | cut -d '.' -f 1 | sort | xargs)
  prompt_for_choice $options "Please select a bootstrap type"
  [ $? -ne 0 ] && return 1
  ./bootstrap_$CHOICE.sh
  heading "Complete!\n"
}


main $@ || print_error "Aborted!\n"
