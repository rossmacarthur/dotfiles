# macOS setup

Not everything is (or should be) automated by the dotfiles bootstrap script.
This document outlines various other steps in setting up a new macOS laptop. I
try to keep this up to date with the latest tools and apps that I am using.

See also

- [Setup Workspace volume](workspace.md)
- [Setup GNU Privacy Guard](../gnupg.md)
- [Setup Visual Studio Code extensions](../vscode.md)

## Package manager

Homebrew is a package manager for macOS. It allows us to install GNU command
line tools and macOS apps using the `brew` command line tool. From the
[homepage](https://brew.sh) follow the installation instructions.

## Core apps

- [Docker for
  Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac)
  ```
  brew install --cask docker
  ```

- [iTerm2](https://iterm2.com): Better Terminal.
  ```
  brew install --cask iterm2
  ```
  - iTerm2 > Preferences > General > Preferences > Load preferences from a custom
    folder or URL: *set to ~/.dotfiles/src/iterm2*
    Save changes: When quitting

- [Visual Studio Code](https://code.visualstudio.com): Integrated development
  environment for all things.
  ```
  brew install --cask visual-studio-code
  ```

## Communication apps

- [Signal](https://signal.org/install)
  ```
  brew install --cask signal
  ```

- [Slack](https://slack.com/intl/en-za/downloads/mac)
  ```
  brew install --cask slack
  ```

## Other apps

- [Alfred 4](http://alfredapp.com/): Better Spotlight.
  ```
  brew install --cask alfred
  ```
  - System Preferences > Keyboard > Shortcuts > Disable Spotlight
  - Alfred
    - Set Advanced > Set preferences folder > `~/.dotfiles/src/alfred`.
    - Set key shortcut to ⌘ + Space.
    - Set Appearance to Alfred macOS.

- [Etcher](https://www.balena.io/etcher/): Flash OS images to SD cards.
  ```
  brew install --cask balenaetcher
  ```

- [Firefox](https://www.mozilla.org/en-ZA/firefox/new/): Better Safari.
  ```
  brew install --cask firefox
  ```

- [Kap](https://getkap.co/): Screen recorder (GIF / MP4 etc).
  ```
  brew install --cask kap
  ```

- [MEGA](https://mega.nz/): Better iCloud.
  ```
  brew install --cask megasync
  ```
  - Setup up MEGAsync and to sync to ~/Cloud.
  - Preferences > Advanced > Disable overlay icons: ✅

- [Postman](https://www.postman.com/): API development tool.
  ```
  brew install --cask postman
  ```

- [QR Journal](https://www.joshjacob.com/mac-development/qrjournal.php): QR code
  scanning on macOS.
  ```
  brew install --cask qr-journal
  ```

- [Rectangle](https://rectangleapp.com/): Move and resize windows using keyboard
  shortcuts or snap areas.
  ```
  brew install --cask rectangle
  ```
  - Rectangle > Settings > Hide menu bar icon: ✅

- [Scroll Reverser](https://pilotmoon.com/scrollreverser/): Allows you to have a
  different scroll direction on trackpad and external mouse.
  ```
  brew install --cask scroll-reverser
  ```
  For natural for trackpad and non natural for mouse. Select "Reverse Vertical"
  and "Reverse Mouse" only.

- [Spotify](https://www.spotify.com/za/download/mac/): Better Apple Music.
  ```
  brew install --cask spotify
  ```

- [VLC](https://www.videolan.org/index.html): Better Quicktime.
  ```
  brew install --cask vlc
  ```

### Command line tools

- [Android Platform
  Tools](https://developer.android.com/studio/releases/platform-tools.html)
  ```
  brew install --cask android-platform-tools
  ```

- [Minikube](https://minikube.sigs.k8s.io)
  ```
  brew install minikube
  ```

- [Pidcat](https://github.com/JakeWharton/pidcat)
  ```
  brew install pidcat
  ```

## Preferences

### General

- System Preferences > General > Recent items: None
- System Preferences > Mission Control > Mission Control: Automatically
  rearrange spaces based on recent use: ❌
- System Preferences > Dock & Menu Bar > Dock > Size: Small
- System Preferences > Dock & Menu Bar > Dock > Automatically hide and show the Dock: ✅
- System Preferences > Dock & Menu Bar > Wi-Fi > Show in Menu Bar: ✅
- System Preferences > Dock & Menu Bar > Bluetooth > Show in Menu Bar: ✅
- System Preferences > Dock & Menu Bar > Sound > Show in Menu Bar: ✅
- System Preferences > Dock & Menu Bar > Battery > Show Percentage: ✅
- System Preferences > Siri > Enable Ask Siri: ❌
- System Preferences > Accessibility > Display > Reduce motion: ✅
- System Preferences > Accessibility > Display > Reduce transparency: ✅
- System Preferences > Keyboard > Keyboard > Key Repeat: Fast
- System Preferences > Keyboard > Keyboard > Delay Until Repeat: Short
- System Preferences > Keyboard > Text: *Remove all abbreviations*
- System Preferences > Keyboard > Shortcuts > Mission Control
  - Switch to Desktop 1: ✅
  - Switch to Desktop 2: ✅
  - Switch to Desktop 3: ✅
- System Preferences > Mouse > Secondary click > Click on right side

- Run the following to disable keyboard Click and Hold
```sh
defaults write -g ApplePressAndHoldEnabled -bool false
```

Change the computer host name
```
sudo scutil --set HostName lt-ross
```

### Finder

- Finder > Preferences > General > Show these items on the desktop: *deselect all*
- Finder > Preferences > General > New Finder windows show: *home*
- Finder > Preferences > Sidebar > Tags: *deselect all*
- Finder > Preferences > Sidebar > Favourites:
  - Applications: ✅
  - Documents: ✅
  - Downloads: ✅
  - Pictures: ✅
  - ross: ✅
- Finder > Preferences > Sidebar > Locations: *select all*
- Finder > Preferences > Sidebar > Tags: *deselect all*
- Finder > Preferences > Advanced > Show all filename extensions: ✅
- Finder > Preferences > Advanced > Keep folders on top > In windows when sorting by name: ✅

### iTerm 2

Install dotfiles by cloning the repository.
```bash
git clone https://github.com/rossmacarthur/dotfiles.git ~/.dotfiles
```

And running the bootstrap script.
```bash
~/.dotfiles/bootstrap/bootstrap.sh
```

Install Powerline fonts.
```sh
git clone https://github.com/powerline/fonts.git
```

Open the "Font Book" app, click the Plus (+) and open the fonts/SourceCodePro
directory.

Compile terminfo
```sh
tic ~/.dotfiles/src/terminfo/xterm-256color.terminfo
```

Set iTerm 2 > Preferences > Preferences > Load preferences from a custom folder
or URL to `~/.dotfiles/src/iterm2`
