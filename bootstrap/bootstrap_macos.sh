#!/usr/bin/env bash

# ---------------------------------------------------------------------------- #
if heading_if "Installs"; then
# ---------------------------------------------------------------------------- #

subheading "Homebrew packages"
update_package_manager
install_package "bash" "Bash"
install_package "curl" "cURL"
install_package "git" "Git"
install_package "htop" "htop"
install_package "jq"
install_package "sheldon"
install_package "tmux"
install_package "tree" "Tree"
install_package "vim" "Vim"
install_package "wget" "Wget"
install_package "zsh" "Zsh"

subheading "Launch Agents"
install_launch_agent "remap-keys" "io.macarthur.ross.remap-keys"

subheading "Scripts"
symlink "bin/cargo-grcov.sh" ".local/bin/cargo-grcov"
symlink "bin/gensshkey.sh"   ".local/bin/gensshkey"
symlink "bin/ips.py"         ".local/bin/ips"
symlink "bin/remap-keys.sh"  ".local/bin/remap-keys"

fi
# ---------------------------------------------------------------------------- #
if heading_if "Python development" "python"; then
# ---------------------------------------------------------------------------- #

subheading "Brew packages"
install_package "openssl" "OpenSSL"
install_package "readline" "Readline"
install_package "sqlite3" "SQLite"
install_package "xz" "XZ"
install_package "zlib"

subheading "Environment"
install_pyenv
install_pyenv_python2
install_pyenv_python3
create_pyenv_virtualenv

subheading "Packages"
install_python_package "awscli"
install_python_package "nanocom" "Nanocom"
install_python_package "passthesalt" "PassTheSalt"

fi
# ---------------------------------------------------------------------------- #
if heading_if "Rust development" "rust"; then
# ---------------------------------------------------------------------------- #

subheading "Environment"
install_rustup
install_rust_version "stable"
install_rust_version "beta"

subheading "Packages"
install_cargo_package "bat"
install_cargo_package "cargo-edit"
install_cargo_package "just"
install_cargo_package "ripgrep"

fi
# ---------------------------------------------------------------------------- #
if heading_if "Configurations" "configs"; then
# ---------------------------------------------------------------------------- #

subheading "General"
symlink "curl/curlrc"             ".curlrc"
symlink "git/gitconfig"           ".gitconfig"
symlink "git/gitignore_global"    ".gitignore_global"
symlink "sheldon/plugins.toml"    ".sheldon/plugins.toml"
symlink "tmux/tmux.conf"          ".tmux.conf"
symlink "vim/vimrc"               ".vimrc"
symlink "vscode/settings.json"    "Library/Application Support/Code/User/settings.json"
symlink "vscode/keybindings.json" "Library/Application Support/Code/User/keybindings.json"

subheading "Zsh"
symlink "zsh/zshrc" ".zshrc"
symlink_zsh_plugin "aliases"
symlink_zsh_plugin "macos/aliases" "aliases_bootstrap"
symlink_zsh_plugin "compinit"
symlink_zsh_plugin "gpg-agent"
symlink_zsh_plugin "pyenv"

fi
