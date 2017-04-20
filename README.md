# dotfiles

### Setup

```bash
bash -c "$(curl -LsS https://raw.github.com/rossmacarthur/dotfiles/master/bootstrap/bootstrap.sh)"
```

**or**

```bash
bash -c "$(wget -qO - https://raw.github.com/rossmacarthur/dotfiles/master/bootstrap/bootstrap.sh)"
```

The bootstrap process in action:

![setup process](https://cloud.githubusercontent.com/assets/17109887/24918585/27f55928-1ee1-11e7-93d7-85aeda94609b.gif)

### Customization

The install script is designed to be very easy to create your own bootstrap. Simply:

* Fork this repository.
* Copy one of the other bootstrap scripts such as [bootstrap_Device.sh](https://github.com/rossmacarthur/dotfiles/blob/master/bootstrap/bootstrap_Device.sh) and call it `bootstrap_Custom.sh` (anything of the form `bootstrap_xxxxx.sh` will work).
* Modify it to your liking. You can use the install functions in [installs.sh](https://github.com/rossmacarthur/dotfiles/blob/master/bootstrap/installs.sh).
* Change the top line of [bootstrap.sh](https://github.com/rossmacarthur/dotfiles/blob/master/bootstrap/bootstrap.sh) to reference your own fork as well as the code snippet at the top of this README.
* Run the bootstrap script and your custom bootstrap will be presented as a bootstrap option.

### Acknowledgements

Inspired by [Cătălin Mariș's](https://github.com/alrra) [dotfiles](https://github.com/alrra/dotfiles).
