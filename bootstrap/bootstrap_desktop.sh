#!/usr/bin/env bash

. installs.sh


heading "Installs"

subheading "System packages"
update_package_manager

if os_is "darwin"; then
  install_package "cURL"            "curl"
  install_package "Git"             "git"
  install_package "Hub"             "hub"
  install_package "htop"            "htop"
  install_package "Python 2"        "python@2"
  install_package "Python 3"        "python@3"
  install_package "tmux"            "tmux"
  install_package "tmux-pasteboard" "reattach-to-user-namespace"
  install_package "Vim"             "vim --with-override-system-vi"
  install_package "Zsh"             "zsh"
else
  install_package "cURL"            "curl"
  install_package "Git"             "git"
  install_package "htop"            "htop"
  install_package "parted"          "parted"
  install_package "Pinta"           "pinta"
  install_package "Python 2"        "python"
  install_package "Python 2 Dev"    "python-dev"
  install_package "Python 3"        "python3"
  install_package "Python 3 Dev"    "python3-dev"
  install_package "tmux"            "tmux"
  install_package "Vim"             "vim"
  install_package "xclip"           "xclip"
  install_package "Zsh"             "zsh"
fi

subheading "Python 3 packages"
install_pip3
install_pip3_package "awscli"      "awscli"
install_pip3_package "Flake8"      "flake8"
install_pip3_package "Nanocom"     "nanocom"
install_pip3_package "PassTheSalt" "passthesalt"
install_pip3_package "Virtualenv"  "virtualenv"

subheading "Oh My Zsh"
clone_oh_my_zsh

subheading "Base16 Shell Theme"
clone_base16_shell_theme

subheading "Vim plugins"
clone_vim_flake8_plugin
clone_vim_base16_themes


heading "Create symbolic links"

subheading "Configurations"
symlink "git/gitconfig"               ".gitconfig"
symlink "git/gitignore_global"        ".gitignore_global"
symlink "tmux/tmux.conf"              ".tmux.conf"
symlink "vim/vimrc"                   ".vimrc"
if os_is "darwin"; then
  symlink "vscode/settings.json"      "Library/Application Support/Code/User/settings.json"
  symlink "vscode/keybindings.json"   "Library/Application Support/Code/User/keybindings.json"
else
  symlink "vscode/settings.json"      ".config/Code/User/settings.json"
  symlink "vscode/keybindings.json"   ".config/Code/User/keybindings.json"
fi
symlink "zsh/zshrc"                   ".zshrc"
symlink "zsh/aliases"                 ".aliases"
symlink "zsh/aliases.${PLATFORM}"     ".aliases.os"
symlink "zsh/completions/passthesalt" ".oh-my-zsh/completions/_passthesalt"
symlink "zsh/rossmacarthur.zsh-theme" ".oh-my-zsh/themes/rossmacarthur.zsh-theme"

subheading "Scripts"

if ! os_is "darwin"; then
  symlink "bin/capslock.py" ".local/bin/capslock"
  symlink "bin/femtocom.sh" ".local/bin/femtocom"
fi
symlink "bin/gensshkey.sh"  ".local/bin/gensshkey"
