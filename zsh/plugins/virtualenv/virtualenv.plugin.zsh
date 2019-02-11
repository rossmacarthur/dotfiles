virtualenv_prompt_info() {
  local pyenv_version=$(pyenv version-name 2>/dev/null)
  local virtualenv_version=$(basename "$VIRTUAL_ENV" 2>/dev/null)
  local venv=${virtualenv_version:=$pyenv_version}

  if [[ ! -z "$venv" ]] && [ "$venv" != "global" ]; then
    echo "${ZSH_THEME_VIRTUALENV_PREFIX:=(}${venv}${ZSH_THEME_VIRTUALENV_SUFFIX:=)}"
  fi
}

# disables prompt mangling in virtual_env/bin/activate
export VIRTUAL_ENV_DISABLE_PROMPT=1

# disables pyenv prompt changing
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
