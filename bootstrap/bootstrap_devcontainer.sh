#!/usr/bin/env bash

# ---------------------------------------------------------------------------- #
if heading_if "Installs"; then
# ---------------------------------------------------------------------------- #

request_sudo || abort

subheading "System packages"
update_package_manager
install_package "fd-find" "fd"
install_package "ripgrep"
install_package "zsh" "Zsh"

subheading "Binaries"
install_crate "sharkdp/bat"
install_crate "rossmacarthur/sheldon"
install_crate "starship/starship"
install_uv

subheading "Scripts"
symlink "bin/gbDs.sh" ".local/bin/gbDs"

fi
# ---------------------------------------------------------------------------- #
if heading_if "Configurations" "configs"; then
# ---------------------------------------------------------------------------- #

subheading "General"
symlink "curl/curlrc"            ".curlrc"
symlink "git/config"             ".config/git/config"
symlink "git/ignore"             ".config/git/ignore"
symlink "sheldon/plugins.toml"   ".config/sheldon/plugins.toml"
symlink "starship/starship.toml" ".config/starship.toml"

subheading "Zsh"
symlink "zsh/zshrc" ".zshrc"
symlink_zsh_plugin "aliases"
symlink_zsh_plugin "compinit"
symlink_zsh_plugin "git"
symlink_zsh_plugin "history"
symlink_zsh_plugin "keybindings"
symlink_zsh_plugin "path"

fi
