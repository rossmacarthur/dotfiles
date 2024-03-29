#!/usr/bin/env bash

# ---------------------------------------------------------------------------- #
if heading_if "Installs"; then
# ---------------------------------------------------------------------------- #

subheading "Homebrew packages"
update_package_manager
install_package "bash" "Bash"
install_package "bat"
install_package "curl" "cURL"
install_package "docker" "Docker"
install_package "git" "Git"
install_package "gnupg" "GnuPG"
install_package "hyperfine"
install_package "jq"
install_package "shellcheck" "ShellCheck"
install_package "tmux"
install_package "pinentry-mac" "PINEntry"
install_package "pipx"
install_package "ripgrep"
install_package "sheldon"
install_package "tree" "Tree"
install_package "vim" "Vim"
install_package "zsh" "Zsh"

subheading "Launch Agents"
install_launch_agent "remap-keys" "io.macarthur.ross.remap-keys"

subheading "Scripts"
symlink "bin/gbDs.sh"        ".local/bin/gbDs"
symlink "bin/gensshkey.sh"   ".local/bin/gensshkey"
symlink "bin/gif2mp4.sh"     ".local/bin/gif2mp4"
symlink "bin/ips.py"         ".local/bin/ips"
symlink "bin/remap-keys.sh"  ".local/bin/remap-keys"

fi
# ---------------------------------------------------------------------------- #
if heading_if "Go development" "go"; then
# ---------------------------------------------------------------------------- #

subheading "Brew packages"
install_package "go"

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
install_pyenv_python3
create_pyenv_virtualenv

fi
# ---------------------------------------------------------------------------- #
if heading_if "Rust development" "rust"; then
# ---------------------------------------------------------------------------- #

subheading "Environment"
install_rustup
install_rust_toolchain "stable"
install_rust_toolchain "beta"
install_rust_toolchain "nightly"

subheading "Packages"
install_cargo_package "kb-remap"

fi
# ---------------------------------------------------------------------------- #
if heading_if "Configurations" "configs"; then
# ---------------------------------------------------------------------------- #

subheading "General"
symlink "curl/curlrc"             ".curlrc"
symlink "git/config"              ".config/git/config"
symlink "git/ignore"              ".config/git/ignore"
symlink "sheldon/plugins.toml"    ".config/sheldon/plugins.toml"
symlink "tmux/tmux.conf"          ".config/tmux/tmux.conf"
symlink "vim/vimrc"               ".vimrc"
symlink "vscode/settings.json"    "Library/Application Support/Code/User/settings.json"
symlink "vscode/keybindings.json" "Library/Application Support/Code/User/keybindings.json"

subheading "Zsh"
symlink "zsh/zprofile" ".zprofile"
symlink "zsh/zshrc"    ".zshrc"
symlink_zsh_plugin "aliases"
symlink_zsh_plugin "macos/aliases" "aliases_bootstrap"
symlink_zsh_plugin "compinit"
symlink_zsh_plugin "gpg-agent"
symlink_zsh_plugin "jetbrains"
symlink_zsh_plugin "nvm"
symlink_zsh_plugin "path"
symlink_zsh_plugin "pyenv"

fi
