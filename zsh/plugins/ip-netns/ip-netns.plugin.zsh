# Get ip netns information
ip_netns_prompt_info() {
  if (( $+commands[ip] )); then
    local ref="$(ip netns identify $$)"
    if [[ ! -z "$ref" ]]; then
      echo "($ref) "
    fi
  fi
}

# Shortcuts for moving to some namespaces
alias ethernet="ip netns exec ethernet"
alias wifi="ip netns exec wifi"
alias mobile="ip netns exec mobile"
