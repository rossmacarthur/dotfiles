#!/usr/bin/env bash

upgrade_pip_setuptools_and_wheel() {
  PYENV_VERSION=$VIRTUALENV_NAME pyenv-exec pip install --upgrade pip setuptools wheel
}

after_virtualenv "upgrade_pip_setuptools_and_wheel"
