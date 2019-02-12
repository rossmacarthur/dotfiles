# disables prompt mangling in venv/bin/activate
export VIRTUAL_ENV_DISABLE_PROMPT=1

virtualenv_prompt_info() {
  local venv=$(basename "$VIRTUAL_ENV" 2>/dev/null)

  if [[ ! -z "$venv" ]] && [ "$venv" != "global" ]; then
    echo "${ZSH_THEME_VIRTUALENV_PREFIX:=(}${venv}${ZSH_THEME_VIRTUALENV_SUFFIX:=)}"
  fi
}
