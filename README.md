# dotfiles

[![Build Status](https://github.com/rossmacarthur/dotfiles/workflows/build/badge.svg)](https://github.com/rossmacarthur/dotfiles/actions?query=workflow%3Abuild)

Install packages and and my personal dotfiles on a new system.

## Getting started

Clone the repository with
```bash
git clone https://github.com/rossmacarthur/dotfiles.git ~/.dotfiles
```

And run the bootstrap script using
```bash
~/.dotfiles/bootstrap/bootstrap.sh
```

The dotfiles script makes some assumptions about the environment, for example on
macOS it expects Homebrew to be installed. For a brand new setup it's best to
follow the [docs](./docs/macos/README.md).

## Acknowledgements

Inspired by [Cătălin Mariș's](https://github.com/alrra)
[dotfiles](https://github.com/alrra/dotfiles).

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
  http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.
