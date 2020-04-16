#!/usr/bin/env zsh

if [ "$DOTFILES_BOOTSTRAP" = "macos" ]; then

  # Copy iTerm2 plist file back to .dotfiles
  sync_iterm2_config() {
    rsync ~/Library/Preferences/com.googlecode.iterm2.plist ~/.dotfiles/iterm2/iterm2.plist
    plutil -convert xml1 ~/.dotfiles/iterm2/iterm2.plist
    echo "Synced ~/Library/Preferences/com.googlecode.iterm2.plist to ~/.dotfiles/iterm2/iterm2.plist"
  }

fi
