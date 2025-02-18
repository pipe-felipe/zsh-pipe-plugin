# ZSH personal plugin

---

## Commands

| Command                  | Description                                                               |
|--------------------------|---------------------------------------------------------------------------|
| `dockerps`               | List  container stopped and running and volumes                           |
| `update`                 | System update like ap, dnf, etc... with snaps flatpak and brew as well    |
| `clean`                  | System cleanup like apt, dnf, etc... with snaps flatpak and brew as well  |
| `install-zsh-plugin`     | Install a custom plugin with 'link' and 'plugin-name'                     |
| `install-favorites`      | Install all my favorite plugins - see on My Favorite Plugins - down below |
| `this-update`            | Update this plugin                                                        |
| `change_alacritty_theme` | Change alacritty theme - light or dark                                    |

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

`change_alacritty_theme`: <br>

This command need the `alacritty.yml` file on the path `~/.alacritty.toml`
and the configuration structure should be like this:
```toml
import = [
#    "~/.config/alacritty/themes/themes/rose-pine-dawn.toml"
    "~/.config/alacritty/themes/themes/everforest_dark.toml"
]
```

The first one should be light and the second one should be dark
