#!/usr/bin/env zsh

if [[ -n "$SSH_AUTH_SOCK" && "$SSH_AUTH_SOCK" != */com.apple.launchd* ]]; then
  return &>/dev/null || exit 0
fi

load_gpg_agent() {
  unset SSH_AGENT_PID
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  gpg-connect-agent updatestartuptty /bye >/dev/null
}

load_gpg_agent
unfunction load_gpg_agent
