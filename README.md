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

## Customization

The install script is designed to be very easy to create your own bootstrap.
Simply:

* Fork this repository and modify the dotfiles to suit you.
* Copy one of the other bootstrap scripts such as [bootstrap_sensor.sh][sensor]
  and call it `bootstrap_custom.sh` (anything of the form `bootstrap_xxxxx.sh`
  will work).
* Modify it to your liking. You can use the install functions in
  [utils.sh][utils].
* Run the bootstrap script and your custom bootstrap will be presented as a
  bootstrap option.

## Acknowledgements

Inspired by [Cătălin Mariș's][alrra] [dotfiles][alrra_dotfiles].

[alrra]: https://github.com/alrra
[alrra_dotfiles]: https://github.com/alrra/dotfiles
[remote]: bootstrap/remote.sh
[sensor]: bootstrap/bootstrap_sensor.sh
[utils]: bootstrap/utils.sh

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
  http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.
