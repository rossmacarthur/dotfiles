#!/usr/bin/env zsh

load_pyenv() {
  # The root folder for pyenv
  export PYENV_ROOT="$HOME/.pyenv"

  # Add pyenv to PATH
  export PATH="$PYENV_ROOT/bin:$PATH"

  # Disables pyenv prompt changing
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1

  # Initialize pyenv
  if (( $+commands[pyenv] )); then
    eval "$(pyenv init - --no-rehash zsh)"
    if [ -f "$PYENV_ROOT/plugins/pyenv-virtualenv/bin/pyenv-virtualenv-init" ]; then
      eval "$(pyenv virtualenv-init - zsh)"
    fi
  fi

}

load_pyenv
unfunction load_pyenv
