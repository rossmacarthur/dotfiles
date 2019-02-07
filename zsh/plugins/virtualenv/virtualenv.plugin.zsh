virtualenv_prompt_info() {
  local venv=${VIRTUAL_ENV:t}

  if [[ ! -z "$venv" ]] && [ "$venv" != "global" ]; then
    echo "${ZSH_THEME_VIRTUALENV_PREFIX:=(}${venv}${ZSH_THEME_VIRTUALENV_SUFFIX:=)}"
  fi
}

# disables prompt mangling in virtual_env/bin/activate
export VIRTUAL_ENV_DISABLE_PROMPT=1

# disables pyenv prompt changing
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
