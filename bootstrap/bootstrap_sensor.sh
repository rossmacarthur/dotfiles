#!/usr/bin/env bash

install_pip() {
  if command_exists pip; then
    execute "pip install --upgrade pip" "PIP 2"
  else
    execute "curl -LsSo get-pip.py https://bootstrap.pypa.io/get-pip.py" "Download get-pip.py"
    execute "sudo python get-pip.py" "PIP"
    rm -f get-pip.py
  fi
}

install_pip_package() {
  local msg=${2:-$1}
  execute "pip install --upgrade $1" "$msg"
}

request_sudo || abort

subheading "System packages"
execute "sudo apt update" "APT (update)"
install_package "cURL"     "curl"
install_package "Git"      "git"
install_package "Python 2" "python"
install_package "tmux"     "tmux"
install_package "Vim"      "vim"
install_package "Zsh"      "zsh"

subheading "Python packages"
install_pip
install_pip_package "nanocom"
install_pip_package "setuptools"
install_pip_package "virtualenv"
install_pip_package "wheel"

subheading "Remote repositories"
clone_oh_my_zsh
clone_base16_shell_theme

subheading "Vim plugins"
clone_vim_base16_themes

subheading "Configurations"
symlink "git/gitconfig"        ".gitconfig"
symlink "git/gitignore_global" ".gitignore_global"
symlink "tmux/tmux.conf"       ".tmux.conf"
symlink "vim/vimrc"            ".vimrc"
symlink "zsh/aliases/sensor"   ".aliases"
symlink "zsh/plugins/sensor"   ".plugins"
symlink "zsh/zshrc"            ".zshrc"

subheading "Scripts"
symlink "bin/femtocom.sh"  ".local/bin/femtocom"
symlink "bin/gensshkey.sh" ".local/bin/gensshkey"
symlink "bin/ips.py"       ".local/bin/ips"
symlink "bin/resize.py"    ".local/bin/resize"
