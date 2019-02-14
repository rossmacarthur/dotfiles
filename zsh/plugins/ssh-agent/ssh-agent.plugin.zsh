_is_ssh_key_added() {
  local result

  result=$(ssh-add -l 2>&1)

  if (( ? == 0 )); then
    return 0
  fi

  if [ "$result" = "The agent has no identities." ]; then
    return 1
  elif [ "$result" = "Error connecting to agent*" ] ||
       [ "$result" = "Could not open a connection to your authentication agent." ]; then
    return 2
  fi
}

_is_ssh_key_added
is_ssh_key_added=$?

if (( is_ssh_key_added == 2 )); then
  eval "$(ssh-agent -s)" >/dev/null 2>&1
fi

if (( is_ssh_key_added != 0 )); then
  ssh-add >/dev/null 2>&1
fi

unset is_ssh_key_added
