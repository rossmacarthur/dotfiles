#!/usr/bin/env zsh

# Cache an external command's initialization script: evalcache COMMAND [ARG...]
#
# brew, sheldon, starship have hardcoded cache busting based on config files
evalcache() {
    local -a reply
    _evalcache_prepare "$@" || return
    # Generator arguments aren't arguments to the generated initialization code
    set --
    # Keep execution outside the helper's local options so prompt/history options persist
    builtin "${reply[@]}"
}

_evalcache_prepare() {
    emulate -L zsh
    if (( ! $# )); then
        print -u2 -- 'Usage: evalcache COMMAND [ARG...]'
        return 2
    fi

    local executable
    if [[ $1 == */* ]]; then
        executable=$1
    else
        executable=${commands[$1]}
    fi
    if [[ ! -f $executable || ! -x $executable ]]; then
        print -u2 -- "evalcache: executable not found: $1"
        return 127
    fi

    local invocation="${(j: :)${(@qqqq)@}}"
    local context="$ZSH_VERSION ${(qqqq)HOME} $invocation"
    local -a dependencies=("${(%):-%x}" "${executable:A}")
    case ${1:t} in
        brew)
            local repository=${executable:A:h:h}
            dependencies+=(
                "$repository/Library/Homebrew/cmd/shellenv.sh"
                "$repository/Library/Homebrew/cmd/shellenv.rb"
            )
            context+=" ${(qqqq)PATH}"
            ;;
        sheldon)
            local config_dir=${SHELDON_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/sheldon}
            local data_dir=${SHELDON_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/sheldon}
            dependencies+=(
                "${SHELDON_CONFIG_FILE:-$config_dir/plugins.toml}"
                "$data_dir/plugins${SHELDON_PROFILE:+.$SHELDON_PROFILE}.lock"
                "$HOME/.zsh/plugins"
            )
            ;;
        starship)
            dependencies+=("${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml}")
            ;;
    esac

    local root="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/evalcache"
    local identity=${1:t}
    local entry="$root/$identity.current"
    local generation key saved script REPLY

    zmodload -F zsh/stat b:zstat || return
    _evalcache_key "$context" "${dependencies[@]}" || return
    key=$REPLY
    if [[ -r $entry ]] && IFS= read -r generation < "$entry" \
        && [[ -r $generation/init.zsh && -s $generation/init.zsh.zwc ]] \
        && IFS= read -r saved < "$generation/init.zsh" && [[ $saved == $key ]]; then
        reply=(source "$generation/init.zsh")
        return 0
    fi

    script=$(command "$@") || return
    reply=(eval "$script")
    _evalcache_key "$context" "${dependencies[@]}" || return 0
    key=$REPLY
    [[ -d $root ]] || command mkdir -p -- "$root" || return 0
    generation=$(command mktemp -d "$root/$identity.XXXXXXXX") || return 0

    if { print -r -- "$key"; print -r -- "$script"; } >| "$generation/init.zsh" \
        && zcompile -RU "$generation/init.zsh" \
        && print -r -- "$generation" >| "$generation/current" \
        && command mv -f -- "$generation/current" "$entry"; then
        reply=(source "$generation/init.zsh")
    else
        command rm -rf -- "$generation"
    fi
    # Keep published generations immutable: another shell may still be sourcing one
    return 0
}

_evalcache_key() {
    local context=$1 dependency
    shift
    local -A metadata
    local -a modified
    REPLY="# ${(qqqq)context}"
    for dependency in "$@"; do
        dependency=${dependency:A}
        REPLY+=" ${(qqqq)dependency}:"
        if zstat -H metadata -- "$dependency" 2>/dev/null; then
            # The default numeric timestamps lose updates within the same second
            zstat -A modified -F '%s.%N' +mtime -- "$dependency" 2>/dev/null || return
            REPLY+="$metadata[device]:$metadata[inode]:$metadata[size]:$modified[1]:$metadata[ctime]"
        else
            REPLY+="missing"
        fi
    done
}
