# ZSH personal plugin

---

## Commands

| Command                  | Description                                                               |
|--------------------------|---------------------------------------------------------------------------|
| `dockerps`               | List  container stopped and running and volumes                           |
| `nvidia-check`           | Full NVIDIA driver health check (hardware, modules, DKMS, Secure Boot)    |
| `update`                 | System update like apt, dnf, etc... with snaps flatpak and brew as well   |
| `clean`                  | System cleanup like apt, dnf, etc... with snaps flatpak and brew as well  |
| `install-zsh-plugin`     | Install a custom plugin with 'link' and 'plugin-name'                     |
| `install-favorites`      | Install all my favorite plugins - see on My Favorite Plugins - down below |
| `this-update`            | Update this plugin                                                        |
| `aur-update-all`         | Update all AUR packages - This command is also in the update in archlinux |

---

| Alias            | Description                             |
|------------------|-----------------------------------------|
| `docker-cleanup` | Cleanup containers, volumes and network |
| `flat-builder`   | Flatpak builder alias                   |

---

| Paths                  |
|------------------------|
| JetBrains scripts path |

---

## Configurations

* To fix this error

``` bash
zsh-pipe-plugin.plugin.zsh:source:1: no such file or directory: /colors.zsh
```

* Add it on .zshrc

This must be on the very top of the file
```bash
export PIPE_PLUGIN="$HOME/.oh-my-zsh/custom/plugins/zsh-pipe-plugin/"
```


### install this plugin

```bash
git clone https://github.com/pipe-felipe/zsh-pipe-plugin ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-pipe-plugin
```

### My favorite plugins

* `https://github.com/zsh-users/zsh-autosuggestions`
* `https://github.com/zsh-users/zsh-syntax-highlighting`

### Install any plugin

```bash
git clone $plugin_link ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name
```

---

### How to connect a functions folder to extends this plugin

Sometimes you shall need to extend a functionality, but this functions has some keys or sensitive data that can't be
updated at some git platform.
You can do it just adding the follow line at your `.zshrc`

````shell
export EXTENDED_FUNCTIONS_FOLDER=/path/to/folder/
````

This path should have a `main.zsh` file that imports all other files that you need

## Commands

### Archlinux

In archlinux, the `update` command will update all AUR packages as well

### MacOS

In MacOS, the `update` command will update all brew packages

### Linux

In every supported linux distribution (archlinux, ubuntu, neon, debian, suse, fedora), the `update` command will update all packages.

Included snap, flatpak and brew as well if they are installed

### Bluefin

On Bluefin, `update` runs `ujust update` and `clean` runs `ujust clean-system` for the immutable base system, instead of `dnf`. Snap, Flatpak and Homebrew are still updated/cleaned the same shared way as on every other supported system.
