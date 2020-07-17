#!/usr/bin/env zsh

set_cargo_target_dir() {
  local dir="$HOME/.cargo/cache/target"
  mkdir -p "$dir"
  export CARGO_TARGET_DIR="$dir/$PWD:t"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd set_cargo_target_dir
set_cargo_target_dir
