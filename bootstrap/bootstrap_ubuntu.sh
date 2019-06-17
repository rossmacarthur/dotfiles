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

request_sudo || abort

heading "General"

subheading "System packages"
update_package_manager
install_package "bash" "Bash"
install_package "curl" "cURL"
install_package "git" "Git"
install_package "make"
install_package "tmux"
install_package "xclip"
install_package "vim" "Vim"
install_package "wget" "Wget"
install_package "zsh" "Zsh"

subheading "Remote repositories"
clone_oh_my_zsh
clone_base16_shell_theme

subheading "Vim plugins"
clone_vim_flake8_plugin
clone_vim_base16_themes

subheading "Configurations"
symlink "curl/curlrc"             ".curlrc"
symlink "git/gitconfig"           ".gitconfig"
symlink "git/gitignore_global"    ".gitignore_global"
symlink "tmux/tmux.conf"          ".tmux.conf"
symlink "vim/vimrc"               ".vimrc"
symlink "vscode/settings.json"    ".config/Code/User/settings.json"
symlink "vscode/keybindings.json" ".config/Code/User/keybindings.json"
symlink "zsh/plugins.toml"        ".zsh/plugins.toml"
symlink "zsh/zshrc"               ".zshrc"
symlink_zsh_plugin "aliases"
symlink_zsh_plugin "ubuntu/aliases" "aliases_bootstrap"
symlink_zsh_plugin "ip-netns"
symlink_zsh_plugin "obfuscate"
symlink_zsh_plugin "pyenv"
symlink_zsh_plugin "ssh-agent"

subheading "Scripts"
symlink "bin/femtocom.sh"  ".local/bin/femtocom"
symlink "bin/gensshkey.sh" ".local/bin/gensshkey"
symlink "bin/ips.py"       ".local/bin/ips"
symlink "bin/pdfshrink.sh" ".local/bin/pdfshrink"

if [ "$INSTALL_PYTHON_TOOLS" = true ]
then
  heading "Python development"

  subheading "System packages"
  install_packages "build-essential" "llvm"
  install_packages "libbz2-dev" "libffi-dev" "liblzma-dev" "libncurses5-dev" "libreadline-dev" \
                   "libsqlite3-dev" "libssl-dev" "libxml2-dev" "libxmlsec1-dev" "zlib1g-dev"

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
fi
