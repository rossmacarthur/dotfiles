# How to setup GNU Privacy Guard (from backup)

The following installs are required.

```sh
brew install gnupg pinentry-mac
```

Now restore a `~/.gnupg` folder backup. For example given a `dot.gnupg.tar.gz`
file.

```sh
cd ~
mv path/to/dot.gnupg.tar.gz dot.gnupg.tar.gz
tar xvf dot.gnupg.tar.gz
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

Finally reload the agent.

```sh
gpgconf --reload gpg-agent
```
