# If the SSH agent is not running, then start it.
if ! ps x $SSH_AGENT_PID >/dev/null 2>&1; then
  eval "$(ssh-agent -s)"
fi

# If there are no SSH keys in the agent, then call `ssh-add`
if ! ssh-add -l >/dev/null 2>&1; then
  ssh-add >/dev/null 2>&1
fi
