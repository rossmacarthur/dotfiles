# dotfiles

Install packages and and my personal dotfiles on a new system.

## Getting started

### One liner

```bash
bash -c "$(curl -LsS https://raw.github.com/rossmacarthur/dotfiles/master/bootstrap/remote.sh)"
```

**or**

```bash
bash -c "$(wget -qO - https://raw.github.com/rossmacarthur/dotfiles/master/bootstrap/remote.sh)"
```

### With repository

It is nice to install with the repository, because then you can just `git pull`
to update the dotfiles.

Clone the repository with
```bash
git clone https://github.com/rossmacarthur/dotfiles.git
```

And run the bootstrap script using
```
./dotfiles/bootstrap/bootstrap.sh
```

## Customization

The install script is designed to be very easy to create your own bootstrap.
Simply:

* Fork this repository and modify the dotfiles to suit you.
* Copy one of the other bootstrap scripts such as [bootstrap_sensor.sh][sensor]
  and call it `bootstrap_custom.sh` (anything of the form `bootstrap_xxxxx.sh`
  will work).
* Modify it to your liking. You can use the install functions in
  [installs.sh][installs].
* Change the top line of [remote.sh][remote] to reference your own fork as well
  as the code snippet at the top of this README.
* Run the bootstrap script and your custom bootstrap will be presented as a
  bootstrap option.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file.

## Acknowledgements

Inspired by [Cătălin Mariș's][alrra] [dotfiles][alrra_dotfiles].

[alrra]: https://github.com/alrra
[alrra_dotfiles]: https://github.com/alrra/dotfiles
[installs]: bootstrap/installs.sh
[remote]: bootstrap/remote.sh
[sensor]: bootstrap/bootstrap_sensor.sh
