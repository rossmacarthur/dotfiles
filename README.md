# bootstrap

**Clone the repo:**
```
git clone https://github.com/rossmacarthur/bootstrap.git ~/.bootstrap && cd ~/.bootstrap
```

**Bootstrap the system:**

To symlink dotfiles only:
```
sudo ./bootstrap.sh dotfiles
```

**or**

To install dev packages and dotfiles only:
```
sudo ./bootstrap.sh device
```

**or**

To install dev packages, desktop packages, and dotfiles:
```
sudo ./bootstrap.sh --gnome-terminal desktop
```
