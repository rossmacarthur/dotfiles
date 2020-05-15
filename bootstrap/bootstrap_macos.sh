#!/usr/bin/env bash

# ---------------------------------------------------------------------------- #
heading "Installs"
# ---------------------------------------------------------------------------- #

subheading "Brew packages"
update_package_manager
install_package "bash" "Bash"
install_package "curl" "cURL"
install_package "git" "Git"
install_package "hub" "Hub"
install_package "htop" "htop"
install_package "python@2" "Python 2"
install_package "python@3" "Python 3"
install_package "tmux"
install_package "vim" "Vim"
install_package "wget" "Wget"
install_package "zsh" "Zsh"

subheading "Binary downloads"
install_sheldon

subheading "Scripts"
symlink "bin/cargo-grcov.sh" ".local/bin/cargo-grcov"
symlink "bin/gensshkey.sh"   ".local/bin/gensshkey"
symlink "bin/ips.py"         ".local/bin/ips"
symlink "bin/pdfshrink.sh"   ".local/bin/pdfshrink"

# ---------------------------------------------------------------------------- #
heading "Python development"
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

# ---------------------------------------------------------------------------- #
heading "Rust development"
# ---------------------------------------------------------------------------- #

subheading "Environment"
install_rustup
install_rust_version "stable"
install_rust_version "beta"

subheading "Packages"
install_cargo_package "cargo-edit"
install_cargo_package "just"
install_cargo_package "ripgrep"

# ---------------------------------------------------------------------------- #
heading "Configurations"
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
symlink "zsh/zshrc"                ".zshrc"
symlink_zsh_plugin "aliases"
symlink_zsh_plugin "macos/aliases" "aliases_bootstrap"
symlink_zsh_plugin "gpg-agent"
symlink_zsh_plugin "pyenv"
create_directory "$HOME/.zsh/functions"
