# macOS setup

Not everything is (or should be) automated by the dotfiles bootstrap script.
This document outlines various other steps in setting up a new macOS laptop. I
try to keep this up to date with the latest tools and apps that I am using.

See also

- [Setup dev volume](./dev.md)
- [Setup GNU Privacy Guard](../gnupg.md)
- [Setup Visual Studio Code extensions](../vscode.md)

## Package manager

Homebrew is a package manager for macOS. It allows us to install GNU command
line tools and macOS apps using the `brew` command line tool. From the
[homepage](https://brew.sh) follow the installation instructions.

## Core apps

- [iTerm2](https://iterm2.com): Better Terminal.
  ```
  brew install --cask iterm2
  ```
  - iTerm2 > Preferences > General > Preferences > Load preferences from a custom
    folder or URL: *set to ~/.dotfiles/src/iterm2*
    Save changes: When quitting

- [Rectangle](https://rectangleapp.com/): Move and resize windows using keyboard
  shortcuts or snap areas.
  ```
  brew install --cask rectangle
  ```
  - Rectangle > Preferences > Launch on login: ✓
  - Rectangle > Preferences > Hide menu bar icon: ✓

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

- [Alfred](http://alfredapp.com/): Better Spotlight.
  ```
  brew install --cask alfred
  ```
  - System Preferences > Keyboard > Keyboard Shortcuts > Disable Spotlight
  - Alfred
    - Set Advanced > Set preferences folder > `~/.dotfiles/src/alfred`.
    - Set key shortcut to ⌘ + Space.
    - Set Appearance to Alfred macOS.

- [Docker for
  Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac)
  ```
  brew install --cask docker
  ```

- [Etcher](https://www.balena.io/etcher/): Flash OS images to SD cards.
  ```
  brew install --cask balenaetcher
  ```

- [Firefox](https://www.mozilla.org/en-ZA/firefox/new/): Better Safari.
  ```
  brew install --cask firefox
  ```

- [MEGA](https://mega.nz/): Better iCloud.
  ```
  brew install --cask megasync
  ```
  - Setup up MEGAsync and to sync to ~/Cloud.
  - Preferences > Advanced > Disable overlay icons: ✅

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

- System Settings > General > Language & Region > Number Format: 1,234,567.89
- System Settings > Accessibility > Display > Reduce motion: ✓
- System Settings > Accessibility > Display > Reduce transparency: ✓
- System Settings > Control Centre > Wi-Fi: Show in Menu Bar
- System Settings > Control Centre > Bluetooth: Show in Menu Bar
- System Settings > Control Centre > Sound: Show in Menu Bar
- System Settings > Control Centre > Battery > Show Percentage: ✓
- System Settings > Desktop & Dock > Size: Small
- System Settings > Desktop & Dock > Automatically hide and show the Dock: ✓
- System Settings > Desktop & Dock > Menu Bar > Recent documents, applications and servers: None
- System Settings > Desktop & Dock > Mission Control: Automatically
  rearrange spaces based on recent use: ✗
- System Settings > Displays > More Space: ✓
- System Settings > Keyboard > Key Repeat: Fast
- System Settings > Keyboard > Delay Until Repeat: Short
- System Settings > Keyboard > Text replacements...: *Remove all*
- System Preferences > Keyboard > Keyboard Shortcuts > Screenshots
  - Save picture of screen as a file: ⌃⇧⌘3
  - Copy picture of screen to clipboard: ⇧⌘3
  - Save picture of selected area as a file: ⌃⇧⌘4
  - Copy picture of selected area to clipboard: ⇧⌘4
- System Preferences > Keyboard > Keyboard Shortcuts > Mission Control
  - Switch to Desktop 1: ✓
  - Switch to Desktop 2: ✓
  - Switch to Desktop 3: ✓


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

### Fonts

**Fira Code**

Download from https://github.com/tonsky/FiraCode/releases/latest

**Powerline**

```sh
git clone https://github.com/powerline/fonts.git
```

### iTerm 2

Install dotfiles by cloning the repository.
```bash
git clone https://github.com/rossmacarthur/dotfiles.git ~/.dotfiles
```

And running the bootstrap script.
```bash
~/.dotfiles/bootstrap/bootstrap.sh
```

Compile terminfo
```sh
tic ~/.dotfiles/src/terminfo/xterm-256color.terminfo
```

Set iTerm 2 > Preferences > Preferences > Load preferences from a custom folder
or URL to `~/.dotfiles/src/iterm2`
