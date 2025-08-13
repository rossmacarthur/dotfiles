# GNU Privacy Guard

The following installs are required.

```sh
brew install gnupg pinentry-mac
```

Then use [`gpg-ez.sh`](../src/bin/gpg-ez.sh) to manage GPG.

## Config

Make sure the PINEntry program is specified in `~/.gnupg/gpg-agent.conf`
```
pinentry-program /opt/homebrew/bin/pinentry-mac
```

## SSH control

Use GPG Agent for SSH:

Make sure that the keygrip for the auth sub key is listed in
`~/.gnupg/sshcontrol`. You can find the keygrip like this:
```sh
gpg --list-secret-keys --with-keygrip
```

Make sure to kick the agent after changing.

```sh
gpgconf --kill gpg-agent
```

## Exporting public GPG key

```sh
gpg --armor --export ross@macarthur.io
```

## Exporting public SSH key

```sh
gpg --export-ssh-key ross@macarthur.io
```
