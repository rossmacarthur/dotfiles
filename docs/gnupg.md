# GNU Privacy Guard

The following installs are required.

```sh
brew install gnupg pinentry-mac
```

## Backup

```sh
cd ~/.gnupg
tar cvfz gnupg.tar.gz gpg-agent.conf private-keys-v1.d pubring.kbx sshcontrol tofu.db trustdb.gpg
```

## Restore

Now restore a `~/.gnupg` folder backup. For example given a `gnupg.tar.gz`
file.

```sh
mkdir -p ~/.gnupg
cd ~/.gnupg
mv path/to/gnupg.tar.gz .
tar xvf gnupg.tar.gz
```

Fix any permission issues by running the following.

```sh
chown -R $(whoami) .
find . -type f -exec chmod 600 {} \;
find . -type d -exec chmod 700 {} \;
```

Double check that any paths in `gpgagent.conf` will work for the new system.

```sh
cat gpgagent.conf
```

List the keys.

```sh
gpg --list-keys
```

Finally reload the agent.

```sh
gpgconf --reload gpg-agent
```

## Renewing keys

```sh
gpg --list-keys
```

```sh
expire
```

Extend expire to `1y`.
