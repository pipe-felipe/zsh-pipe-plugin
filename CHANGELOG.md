# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-08-09

### Added

- Added native Bluefin support. On Bluefin, `update` uses `ujust update` and
  `clean` uses `ujust clean-system`.
- Added dedicated system modules for Bluefin, Arch Linux, Fedora, Ubuntu,
  Debian, KDE Neon, openSUSE, and macOS.

### Changed

- Refactored system update and cleanup into registered handlers. Each supported
  system now owns its detection and package-manager commands in its own module.
- Kept `update-cleanup.zsh` distribution-agnostic. It selects a system handler
  and runs shared Snap, Homebrew, and Flatpak steps when the selected system
  does not manage them itself. No handler opts out of this today, including
  Bluefin: `ujust update`/`ujust clean-system` only cover the immutable base
  system, so Snap, Homebrew, and Flatpak still go through the shared steps.

## [1.0.0 - 1.9.9] - Historical baseline

This section was added retrospectively. The project did not need a changelog
while its changes were small and focused; version 2.0.0 introduces a broader
architecture change, making release notes necessary going forward.

### Added

- Shell helpers for Docker, NVIDIA diagnostics, aliases, paths, plugin
  installation, and self-updates.
- System update and cleanup commands for Arch Linux, Fedora, Ubuntu, Debian,
  KDE Neon, openSUSE, and macOS, including support for Snap, Homebrew, and
  Flatpak when available.
- AUR package updates for Arch Linux through `aur-update-all`.
