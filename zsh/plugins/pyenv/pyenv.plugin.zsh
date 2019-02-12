# disables pyenv prompt changing
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

if (( $+commands[pyenv] )); then
  eval "$(pyenv init - zsh)"
  if [ -f "$PYENV_ROOT/plugins/pyenv-virtualenv/bin/pyenv-virtualenv-init" ]; then
    eval "$(pyenv virtualenv-init - zsh)"
  fi
fi
