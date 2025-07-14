#!/usr/bin/env zsh

## History wrapper
function _history {
  # parse arguments and remove from $@
  local clear list stamp REPLY
  zparseopts -E -D c=clear l=list f=stamp E=stamp i=stamp t:=stamp

  if [[ -n "$clear" ]]; then
    # if -c provided, clobber the history file

    # confirm action before deleting history
    print -nu2 "This action will irreversibly delete your command history. Are you sure? [y/N] "
    builtin read -E
    [[ "$REPLY" = [yY] ]] || return 0

    print -nu2 >| "$HISTFILE"
    fc -p "$HISTFILE"

    print -u2 History file deleted.
  elif [[ $# -eq 0 ]]; then
    # if no arguments provided, show full history starting from 1
    builtin fc "${stamp[@]}" -l 1
  else
    # otherwise, run `fc -l` with a custom format
    builtin fc "${stamp[@]}" -l "$@"
  fi
}

# Timestamp format
alias history='_history -i'

## History file configuration
export HISTSIZE=5000000
export SAVEHIST=$HISTSIZE
export HISTFILE="$HOME/.zhistory"

## History command configuration
setopt extended_history       # Write the history file in the ':start:elapsed;command' format
setopt hist_expire_dups_first # Expire a duplicate event first when trimming history
setopt hist_find_no_dups      # Do not display a previously found event
setopt hist_ignore_all_dups   # Delete an old recorded event if a new event is a duplicate
setopt hist_ignore_dups       # Do not record an event that was just recorded again
# setopt hist_ignore_space      # Do not record an event starting with a space
setopt hist_save_no_dups      # Do not write a duplicate event to the history file
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # Share history between all sessions
