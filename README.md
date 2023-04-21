# ZSH personal plugin

---

## Commands

| Command              | Description                                                            |
|----------------------|------------------------------------------------------------------------|
| `dockerps`           | List  container stoped and running and volumes                         |
| `update`             | Sytem update like ap, dnf, etc... with snaps flatpak and brew as well  |
| `clean`              | Sytem clanup like apt, dnf, etc... with snaps flatpak and brew as well |
| `install-zsh-plugin` | Install a custom plugin with 'link' and 'plugin-name'                  |

---

| Alias            | Description                          |
|------------------|--------------------------------------|
| `docker-cleanup` | Cleanup containers and volumes       |

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
`export PIPE_PLUGIN="$HOME/.oh-my-zsh/custom/plugins/zsh-pipe-plugin/"`


### install the plugin

`git clone https://github.com/pipe-felipe/zsh-pipe-plugin ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-pipe-plugin`

### My favorite plugins

`https://github.com/zsh-users/zsh-autosuggestions`
`https://github.com/zsh-users/zsh-syntax-highlighting`

### Install any plugin

`git clone $plugin_link ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name`
