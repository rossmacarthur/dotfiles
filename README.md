# dotfiles

Install packages and and my personal dotfiles on a new system.

## Usage

```bash
bash -c "$(curl -LsS https://raw.github.com/rossmacarthur/dotfiles/master/bootstrap/bootstrap.sh)"
```

**or**

```bash
bash -c "$(wget -qO - https://raw.github.com/rossmacarthur/dotfiles/master/bootstrap/bootstrap.sh)"
```

The bootstrap process in action:

![setup process](https://user-images.githubusercontent.com/17109887/38251198-1295fefa-3751-11e8-9e0d-c607934cb04e.gif)

## Customization

The install script is designed to be very easy to create your own bootstrap. Simply:

* Fork this repository and modify the dotfiles to suit you.
* Copy one of the other bootstrap scripts such as [bootstrap_device.sh](https://github.com/rossmacarthur/dotfiles/blob/master/bootstrap/bootstrap_device.sh) and call it `bootstrap_custom.sh` (anything of the form `bootstrap_xxxxx.sh` will work).
* Modify it to your liking. You can use the install functions in [installs.sh](https://github.com/rossmacarthur/dotfiles/blob/master/bootstrap/installs.sh).
* Change the top line of [bootstrap.sh](https://github.com/rossmacarthur/dotfiles/blob/master/bootstrap/bootstrap.sh) to reference your own fork as well as the code snippet at the top of this README.
* Run the bootstrap script and your custom bootstrap will be presented as a bootstrap option.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file.

## Acknowledgements

Inspired by [Cătălin Mariș's](https://github.com/alrra) [dotfiles](https://github.com/alrra/dotfiles).
