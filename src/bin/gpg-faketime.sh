#!/usr/bin/env bash
#
# This script is used in conjunction with Git to allow you to specify a
# specific date when signing commits with GPG. This is useful for
# rewriting Git history without modifying the signature time.
#
# GPG_FAKETIME should be set to the number of seconds since the epoch.
#
# # Usage:
#
# export GPG_FAKETIME=$(date -v-24H +%s)
# export GIT_AUTHOR_DATE="$GPG_FAKETIME +0200"
# export GIT_COMMITTER_DATE="$GPG_FAKETIME +0200"
# git commit -S -m "Your commit message"

if [ -z "$GPG_FAKETIME" ]; then
    exec /opt/homebrew/bin/gpg "$@"
else
    exec /opt/homebrew/bin/gpg --faked-system-time "$GPG_FAKETIME" "$@"
fi
