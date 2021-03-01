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

- [1Password](https://1password.com/downloads/mac): Password storage and
  management.
  ```
  brew install --cask 1password
  ```

- [Docker for
  Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac)
  ```
  brew install --cask docker
  ```

- [iTerm2](https://iterm2.com): Better Terminal.
  ```
  brew install --cask iterm2
  ```

- [Visual Studio Code](https://code.visualstudio.com): Integrated development
  environment for all things.
  ```
  brew install --cask visual-studio-code
  ```

## Communication apps

- Microsoft Outlook
  ```
  brew install --cask microsoft-outlook
  ```

- [Signal](https://signal.org/install)
  ```
  brew install --cask signal
  ```

- [Slack](https://slack.com/intl/en-za/downloads/mac)
  ```
  brew install --cask slack
  ```

- [Zoom](https://www.zoom.us/)
  ```
  brew install --cask zoomus
  brew install --cask zoomus-outlook-plugin
  ```

## Other apps

- [Alfred 4](http://alfredapp.com/): Better Spotlight.
  ```
  brew install --cask alfred
  ```
  - System Preferences > Keyboard > Shortcuts > Disable Spotlight
  - Alfred
    - Set Advanced > Preferences folder to the `~/.dotfiles/src/alfred` folder.
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

- [MEGAsync](https://mega.nz/): Better iCloud.
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

- System Preferences > Accessibility > Display > Reduce motion: ✅
- System Preferences > Bluetooth > Show Bluetooth in menu bar: ✅
- System Preferences > Dock > Size: Small
- System Preferences > Dock > Automatically hide and show the Dock: ✅
- System Preferences > Energy > Automatic Graphics Switching: ❌
- System Preferences > General > Recent items: None
- System Preferences > Keyboard > Text: *Remove all abbreviations*
- System Preferences > Keyboard > Keyboard > Touch Bar shows: Expanded Control
  strip
- System Preferences > Keyboard > Keyboard > Key Repeat: Fast
- System Preferences > Keyboard > Keyboard > Delay Until Repeat: Short
- System Preferences > Keyboard > Keyboard > Shortcuts > Mission Control
  - Switch to Desktop 1: ✅
  - Switch to Desktop 2: ✅
  - Switch to Desktop 3: ✅
  - Switch to Desktop 4: ✅
- System Preferences > Mission Control > Mission Control > Secondary button:
  Mouse Button 5
- System Preferences > Mission Control > Mission Control: Automatically
  rearrange spaces based on recent use: ❌
- System Preferences > Siri > Enable Ask Siri: ❌
- System Preferences > Sound > Sound Effects > Show volume in menu bar: ✅

- Run the following to disable keyboard Click and Hold
```sh
defaults write -g ApplePressAndHoldEnabled -bool false
```

- Click on battery in Menu Bar, then click Show Percentage.

Run the following to remove all persistent Dock apps:
```sh
defaults write com.apple.dock persistent-apps -array
killall Dock
```

- Finder > Preferences > Advanced > Show all filename extensions: ✅
- Finder > Preferences > Advanced > Keep folders on top > In windows when sorting by name: ✅
- Finder > Preferences > Sidebar > Tags: ❌
- Finder > Preferences > Sidebar > Favourites:
  - Applications: ✅
  - Documents: ✅
  - Downloads: ✅
  - Pictures: ✅
  - ross: ✅
- Finder > Preferences > Sidebar > Locations: *select all*

### Terminal (iTerm 2)

Install dotfiles by following main [README](../../README.md) in this repo. After
starting a new terminal if you get error: "Insecure completion-dependent
directories detected" then run
```sh
compaudit | xargs chmod g-w,o-w
```

Install Powerline fonts.
```sh
git clone https://github.com/powerline/fonts.git`
```

Open the "Font Book" app, click the Plus (+) and open the fonts/SourceCodePro
directory.

Compile terminfo
```sh
tic ~/.dotfiles/src/terminfo/xterm-256color.terminfo
```

Set iTerm 2 > Preferences > Preferences > Load preferences from a custom folder
or URL to `~/.dotfiles/src/iterm2`
