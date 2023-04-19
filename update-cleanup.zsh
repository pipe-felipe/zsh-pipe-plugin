readonly ARCH=/etc/arch-release
readonly FEDORA=/etc/fedora-release

function _os_match() {
  if test -f "$1"; then
    echo "Found file $1"
    return 0
  else
    echo "Could not find file $1"
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
    case 1 in
  "$(_os_match "$ARCH")")
      echo "z"
      ;;
    "$(_os_match "$FEDORA")")
      echo "y"
      ;;
    *)
      echo "Unknown OS"
      ;;
  esac
}
_os_update

function update() {
  if _is_arch; then
    echo -e "${BLUE}${BOLD}\nSYSTEM UPDATE ${RESET}"
    printf "\n"

    echo -e "${GREEN}pacman -Syu"
    sudo pacman -Syu
    printf "==================================================\n"

    printf "==================================================\n"
    echo -e "${BOLD}DONE WITH UPDATE"
  fi
  if _is_installed snap; then
    _update_snap
  fi

  if _is_installed brew; then
    _homebrew_update
  fi

  if _is_installed flatpak; then
    _update_flatpak
  fi
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

function clean() {
  if _is_arch; then
    echo -e "${BLUE}${BOLD}\nSYSTEM CLEANUP ${RESET}"
    printf "\n"

    echo -e "${GREEN}-Rsn pacman -Qtdq"
    sudo pacman -Rns "$(pacman -Qtdq)"
    printf "==================================================\n"

    if _is_installed brew; then
      _cleanup_homebrew
    fi

    if _is_installed flatpak; then
      _cleanup_flatpak
    fi

    printf "==================================================\n"
    echo -e "${BOLD}DONE WITH CLEANUP"
  fi
}
