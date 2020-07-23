#!/usr/bin/env zsh

init_nvm() {
  # The root folder for NVM
  export NVM_DIR="$HOME/.nvm"

  # Initialize NVM
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
}

load_nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"
  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

init_nvm
unfunction init_nvm

autoload -U add-zsh-hook
add-zsh-hook chpwd load_nvmrc
load_nvmrc
