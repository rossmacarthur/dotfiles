# How to setup GNU Privacy Guard (from backup)

The following installs are required.

```sh
brew install gnupg
brew install pinentry-mac
```

Restore a `~/.gnupg` folder backup.

```sh
mkdir -p ~/.gnupg

cp pubring.kbx ~/.gnupg/pubring.kbx
cp private-keys-v1.d/* ~/.gnupg/private-keys-v1.d
cp gpg-agent.conf ~/.gnupg/gpg-agent.conf
cp sshcontrol ~/.gnupg/sshcontrol
```

Note: fix any permission issues by running the following.

```sh
chown -R $(whoami) ~/.gnupg/
find ~/.gnupg -type f -exec chmod 600 {} \;
find ~/.gnupg -type d -exec chmod 700 {} \;
```

List the keys.

```sh
gpg --list-keys
```

Edit the key and ultimately trust the Ross MacArthur key

```sh
gpg --edit-key CEC05F5D492F2823749DB8E5005277386AA61DCD
> trust
> 5
> save
```

Finally reload the agent.

```sh
gpgconf --reload gpg-agent
```
