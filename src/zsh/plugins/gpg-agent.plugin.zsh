#!/usr/bin/env zsh

load_gpg_agent() {
  unset SSH_AGENT_PID
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  gpg-connect-agent updatestartuptty /bye >/dev/null
}

load_gpg_agent
unfunction load_gpg_agent
