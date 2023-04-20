readonly ARCH=/etc/arch-release
readonly FEDORA=/etc/fedora-release
readonly UBUNTU=/etc/os-release

# 0 = true | 1 = false

function _os_match() {
  if test -f "$1"; then
    return 0
  else
    return 1
  fi
}

function _is_installed {
  if command -v "$1" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

function _homebrew_update() {
  echo -e "${YELLOW}brew update"
  brew update
  printf "==================================================\n"

  echo -e "${YELLOW}brew upgrade"
  brew upgrade
  printf "==================================================\n"
}

function _update_snap() {
  echo -e "${YELLOW}snap refresh"
  sudo snap refresh
  printf "==================================================\n"
}

function _update_flatpak() {
  echo -e "${YELLOW}flatpak update"
  flatpak update
  printf "==================================================\n"
}

function _os_update() {
  echo -e "${BLUE}${BOLD}\nSYSTEM UPDATE ${RESET}"
  printf "\n"

  if test -f $FEDORA; then
    echo -e "${GREEN}dnf upgrade"
    sudo dnf upgrade
  fi

  if test -f $ARCH; then
    echo -e "${GREEN}pacman -Syu"
    sudo pacman -Syu
  fi

  if [[ -f "$UBUNTU" ]] && grep -qi "ubuntu" "$UBUNTU"; then
    echo -e "${GREEN}apt update && upgrade"
    sudo apt update
    sudo apt upgrade -y
  fi

  printf "==================================================\n"
  echo -e "${BOLD}DONE WITH UPDATE"
}

function _cleanup_homebrew() {
  echo -e "${YELLOW}brew cleanup"
  brew cleanup
  printf "==================================================\n"

  echo -e "${YELLOW}brew autoremove"
  brew autoremove
  printf "==================================================\n"
}

function _cleanup_flatpak() {
  echo -e "${YELLOW}flatpak --unused"
  flatpak uninstall --unused
  printf "==================================================\n"
}

function _os_clean() {
  echo -e "${BLUE}${BOLD}\nSYSTEM CLEANUP ${RESET}"
  printf "\n"

  if test -f $FEDORA; then
    echo -e "${GREEN}dnf clean all"
    sudo dnf clean all
  fi

  if test -f $ARCH; then
    echo -e "${GREEN}-Rsn pacman -Qtdq"
    sudo pacman -Rns "$(pacman -Qtdq)"
  fi

  if [[ -f "$UBUNTU" ]] && grep -qi "ubuntu" "$UBUNTU"; then
    echo -e "${GREEN}apt clean autoclean autoremove"
    sudo apt autoclean
    sudo apt clean
    sudo apt autoremove -y
  fi

  printf "==================================================\n"
  echo -e "${BOLD}DONE WITH CLEANUP"
}

function update() {
  _os_update

  if _is_installed snap; then _update_snap; fi
  if _is_installed brew; then _homebrew_update; fi
  if _is_installed flatpak; then _update_flatpak; fi
}

function clean() {
  _os_clean

  if _is_installed brew; then _cleanup_homebrew; fi
  if _is_installed flatpak; then _cleanup_flatpak; fi
}
