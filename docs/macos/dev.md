# How to add a separate "dev" volume

## Introduction

By default macOS has a case-insensitive file system. It is often useful to have
a case-*sensitive* file system. For example, if you wanted to Git clone the
Linux source tree. But it's not a good idea to make your entire disk
case-sensitive because some macOS apps are broken and rely on it. The solution
is to create a separate volume for Git clones and work related stuff.

## Creating the volume

- Open Disk Utility.
- Click the + (plus) for a new Volume.
- Set the name to "dev".
- Set the format to "APFS (Case-sensitive, Encrypted)".
- Leave size options as the default.
- Click "Add".

Unmount and mount the volume once making sure to select "Store password in
keychain".

## Permanently mount it at `~/dev`

- Make sure "dev" is unmounted.
- Make sure the directory is created (`mkdir ~/dev`).
- Click on the volume and select "Get info".
- Click on the "File system UUID" and copy it (⌘ + C).
- Run `sudo vifs` to open up safe editing of `/etc/fstab`.
- Add the following to it
```
UUID=4F1AE319-C9CB-436F-9871-A31EF5004C1B /Users/ross/dev apfs rw 0 2
```

where `4F1AE319-C9CB-436F-9871-A31EF5004C1B` is the "File system UUID" value and
`/Users/ross/dev` is the mount point.

You can check if it is working without rebooting by running the following.
```
sudo mount -av
```

If you get permission denied it likely means the password wasn't stored in the
keychain.
