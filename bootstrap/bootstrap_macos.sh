#!/usr/bin/env bash

heading "Configuration"

if confirm --before 1 "Install Python development tools?"
then
  INSTALL_PYTHON_TOOLS=true
fi

if confirm "Install Rust development tools?"
then
  INSTALL_RUST_TOOLS=true
fi

if [ "$INSTALL_PYTHON_TOOLS" = true ]
then
  request_sudo || abort
fi

heading "General"

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
install_package "reattach-to-user-namespace" "tmux-pasteboard"
install_package "vim" "Vim"
install_package "zsh" "Zsh"

subheading "Vim plugins"
clone_vim_flake8_plugin
clone_vim_base16_themes

subheading "Configurations"
symlink "curl/curlrc"             ".curlrc"
symlink "git/gitconfig"           ".gitconfig"
symlink "git/gitignore_global"    ".gitignore_global"
symlink "tmux/tmux.conf"          ".tmux.conf"
symlink "vim/vimrc"               ".vimrc"
symlink "vscode/settings.json"    "Library/Application Support/Code/User/settings.json"
symlink "vscode/keybindings.json" "Library/Application Support/Code/User/keybindings.json"
symlink "zsh/plugins.toml"         ".zsh/plugins.toml"
symlink "zsh/zshrc"                ".zshrc"
symlink_zsh_plugin "aliases"
symlink_zsh_plugin "macos/aliases" "aliases_bootstrap"
symlink_zsh_plugin "iterm2"
symlink_zsh_plugin "obfuscate"
symlink_zsh_plugin "pyenv"
symlink_zsh_plugin "ssh-agent"

subheading "Scripts"
symlink "bin/gensshkey.sh" ".local/bin/gensshkey"
symlink "bin/ips.py"       ".local/bin/ips"
symlink "bin/pdfshrink.sh" ".local/bin/pdfshrink"

if [ "$INSTALL_PYTHON_TOOLS" = true ]
then
  heading "Python development"

  subheading "System packages"
  execute "xcode-select --install || true" "Xcode Command Line Tools"
  execute \
    "sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /" \
    "Additional SDK headers"

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
  install_python_package "flake8" "Flake8"
  install_python_package "nanocom" "Nanocom"
  install_python_package "passthesalt" "PassTheSalt"
fi

if [ "$INSTALL_RUST_TOOLS" = true ]
then
  heading "Rust development"

  subheading "Environment"
  install_rustup

  subheading "Packages"
  install_rustup_component "clippy"
  install_rustup_component "rustfmt"
  install_cargo_package "cargo-edit"
  install_cargo_package "sheldon"
fi
