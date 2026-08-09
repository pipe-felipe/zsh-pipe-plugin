# Testing zsh-pipe-plugin with Podman

Spins up a disposable container per supported distro, mounts the repo
read-only, and loads the plugin exactly like a real `~/.zshrc` would — so you
can poke at `update`/`clean`/`nvidia-check`/etc. against the real package
manager of that distro without touching your host.

## Requirements

* `podman` (rootless is fine; this was built and tested with Podman 5.8 on
  Fedora/Bluefin).

## Quick start

```bash
# Interactive zsh shell on Fedora, plugin already loaded, REAL package manager
teste/run.sh fedora

# Same, for any other supported distro
teste/run.sh archlinux
teste/run.sh ubuntu
teste/run.sh debian
teste/run.sh suse
teste/run.sh neon
teste/run.sh bluefin

# Non-interactive test for one distro: sources the plugin, checks handler
# selection, then actually CALLS update()/clean() against MOCKED
# package-manager binaries and asserts what got invoked
teste/run.sh fedora test

# Same, for every distro, with a pass/fail summary (~4s with a warm image cache)
teste/run.sh all
```

There are two different ways `update`/`clean` get exercised, on purpose:

* **`shell` (interactive)** — the real `pacman`/`apt`/`dnf`/... of that
  container. Use this to manually verify a command actually works end to
  end (hits the real network/mirrors of that container). The container is
  thrown away on exit (`--rm`), so this is safe to run repeatedly.
* **`test` / `all` (automated)** — `mocks/bin/` is prepended to `PATH`, so
  every `pacman`/`apt`/`dnf`/`zypper`/`pkcon`/`ujust`/`snap`/`brew`/
  `flatpak`/`git`/`makepkg`/`vercmp`/`sudo` call is intercepted, logged, and
  answered with canned output — real enough for `aur-update-all` to parse a
  fake `.SRCINFO` and decide to "update" a fake AUR package. `update()`/
  `clean()` run for real through the plugin's own code, so the full call
  graph is exercised, but nothing touches the network or takes more than
  milliseconds. `smoke-test.zsh` then asserts, from the logged calls, that
  e.g. Fedora's `update` actually called `dnf`, and that the shared
  snap/brew/flatpak steps ran too - `ujust update`/`ujust clean-system`
  only cover Bluefin's immutable base system, so Bluefin goes through the
  same shared extras as every other handler (nobody opts out today).

Editing any `.zsh` file in the repo and re-running does **not** require
rebuilding the image: the repo and `mocks/bin/` are bind-mounted, images
only install OS packages (zsh, sudo, git, ...), never a copy of the plugin.

## What each container is

| distro      | base image                                      | how the distro is "detected"                                                                 |
|-------------|--------------------------------------------------|------------------------------------------------------------------------------------------------|
| `archlinux` | `docker.io/library/archlinux:base` + base-devel   | real `/etc/arch-release`. base-devel/git included so `aur-update-all`'s makepkg path also runs |
| `fedora`    | `docker.io/library/fedora:latest`                 | real `/etc/fedora-release`                                                                      |
| `ubuntu`    | `docker.io/library/ubuntu:latest`                 | real `/etc/os-release`                                                                          |
| `debian`    | `docker.io/library/debian:latest`                 | real `/etc/os-release`                                                                          |
| `suse`      | `registry.opensuse.org/opensuse/tumbleweed:latest`| real `/usr/etc/SUSE-brand`                                                                       |
| `neon`      | `docker.io/library/ubuntu:22.04`                  | **synthetic**: no official neon container image exists, so `/etc/os-release` is overwritten with neon's real `ID`/`NAME`/`ID_LIKE` fields. Good enough to test `_neon_is_supported`, not a full neon desktop |
| `bluefin`   | `docker.io/library/fedora:latest`                 | **synthetic**: the real image (`ghcr.io/ublue-os/bluefin`) is several GB and assumes a booted bootc/ostree system where `ujust` recipes behave differently. This container only recreates `/usr/share/ublue-os/image-info.json` (the one file `_bluefin_is_supported` checks) and stubs `ujust` to echo its arguments, on Fedora — Bluefin's real base — so you can confirm the Bluefin handler correctly wins over the Fedora one |

Everything except `neon` and `bluefin` runs against the distro's real,
official base image — including the real `/etc/os-release` /
`/etc/*-release` files, which is what actually exercises the `grep`-based
detection in `variables.zsh` + `*_is_supported`, not just an assumption about
their contents.

`macos.zsh` isn't covered here: it's gated on `$OSTYPE == darwin*`, which
Podman on Linux can't produce. If you need to sanity-check that branch,
override the check manually inside any shell:
`OSTYPE=darwin23 zsh -c 'source zsh-pipe-plugin.plugin.zsh; _select_system_update_handler'`.

## Files

* `run.sh` — build/run entrypoint (see `teste/run.sh -h`-style usage at the
  top of the file).
* `containers/*.Containerfile` — one per distro, installs zsh/sudo/git and a
  passwordless-sudo `tester` user (sudo needs no password so `update`/`clean`
  can run unattended in the container; this only ever affects the throwaway
  container, never the host).
* `tester.zshrc` — copied into every image as `~/.zshrc`; it's the same
  two-line setup described in the main `README.md` (`export PIPE_PLUGIN=...`
  then `source .../zsh-pipe-plugin.plugin.zsh`), so the interactive shell
  boots exactly like a real install.
* `smoke-test.zsh` — non-interactive checker used by the `test`/`all` modes:
  sources the plugin, checks handler selection, then runs `update`/`clean`
  against the mocks and asserts what was called.
* `mocks/bin/_mock-dispatch` — one script, symlinked under every faked
  command name (`pacman`, `apt`, `dnf`, `zypper`, `pkcon`, `ujust`, `snap`,
  `brew`, `flatpak`, `git`, `makepkg`, `vercmp`, `sudo`). Logs every call to
  `$MOCK_LOG` and, for the handful of commands `aur-update-all` actually
  parses output from (`pacman -Q*`, `git clone`, `vercmp`), returns
  plausible fake data instead of just an empty success.
