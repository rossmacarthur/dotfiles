#!/usr/bin/env zsh

__pyenv_virtualenv_last_pwd=
_pyenv_virtualenv_hook_wrap() {
  local ret=$?
  local f_time="$PYENV_ROOT/cache/virtualenv-mtime"
  local f_vers=".python-version"
  if [[
         ( "$__pyenv_virtualenv_last_pwd" != "$PWD" )
      || ( ! -f "$f_vers" && -f "$f_time"  )
      || ( -f "$f_vers" && ! -f "$f_time" )
      || ( "$f_vers" -nt "$f_time" )
  ]]; then
    _pyenv_virtualenv_hook "$@"
    __pyenv_virtualenv_last_pwd="$PWD"
    if [ -f "$f_vers" ]; then
      touch "$f_time"
    else
      rm -f "$f_time"
    fi
  fi
  return $ret
}

load_pyenv() {
  # The root folder for pyenv
  export PYENV_ROOT="$HOME/.pyenv"

  # Disables pyenv prompt changing
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1

  path_push "$PYENV_ROOT/bin"

  if (( $+commands[pyenv] )); then
    eval "$(pyenv init - --no-rehash zsh)"
    path_push "$PYENV_ROOT/shims"
    if [ -f "$PYENV_ROOT/plugins/pyenv-virtualenv/bin/pyenv-virtualenv-init" ]; then
      if [[ -z $precmd_functions[(r)_pyenv_virtualenv_hook_wrap] ]]; then
        eval "$(pyenv virtualenv-init - zsh)"
        shift precmd_functions
        precmd_functions=(_pyenv_virtualenv_hook_wrap $precmd_functions)
        path_push "$PYENV_ROOT/plugins/pyenv-virtualenv/shims"
      fi
    fi
  fi
}

if [[ "$TERMINAL_EMULATOR" != *JetBrains* ]]; then
  load_pyenv
  unfunction load_pyenv
fi
