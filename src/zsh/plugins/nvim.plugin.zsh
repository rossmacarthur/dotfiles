#!/usr/bin/env zsh

[[ -n ${NVIM-} ]] || return 0

_nvim_report_directory() {
    emulate -L zsh
    # Encode UTF-8 bytes, rather than code points, for the file URI
    local LC_ALL=C
    local encoded= char
    for char in "${(@s::)PWD}"; do
        case $char in
            [a-zA-Z0-9/._~-]) ;;
            *) printf -v char '%%%02X' "'$char" ;;
        esac
        encoded+=$char
    done
    printf '\e]7;file://localhost%s\e\\' "$encoded"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _nvim_report_directory
add-zsh-hook precmd _nvim_report_directory
_nvim_report_directory
