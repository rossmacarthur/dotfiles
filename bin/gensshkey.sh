#!/usr/bin/env bash

ask_for_confirmation() {
  unset ANSWER
  printf "${1} (y/n) "
  read -r -n 1 -t 10 ANSWER
  printf "\n"
}

answer_is_yes() {
  [[ "$ANSWER" =~ ^[Yy]$ ]] && return 0 || return 1
}

check_file_exists() {
  if [ -f $1 ]; then
    ask_for_confirmation "${1} already exists. Delete?"
    if answer_is_yes; then
      rm $1 && printf "Deleted ${1}.\n"
    else
      exit 1
    fi
  fi
}

check_file_exists ~/.ssh/id_rsa
check_file_exists ~/.ssh/id_rsa.pub

mkdir -p ~/.ssh

printf "Enter your email address: "
read email
ssh-keygen -t rsa -b 4096 -C "${email}" -N "" <<EOF

EOF

if command -v pbcopy >/dev/null || command -v xclip >/dev/null; then
  ask_for_confirmation "Copy ~/.ssh/id_rsa.pub to clipboard?"
  if answer_is_yes; then
    if command -v pbcopy >/dev/null; then
      cat ~/.ssh/id_rsa.pub | pbcopy
    else
      cat ~/.ssh/id_rsa.pub | xclip -selection clipboard
    fi
    printf "~/.ssh/id_rsa.pub copied to clipboard.\n"
  else
    printf "Not copying ~/.ssh/id_rsa.pub to clipboard.\n"
  fi
fi

printf "Done!\n"
