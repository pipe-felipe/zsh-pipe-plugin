function _is_arch() {
  if test -f /etc/arch-release; then
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

function update() {
    if _is_arch; then
        echo -e "${BLUE}${BOLD}\nSYSTEM UPDATE ${RESET}"
        printf "\n"

        echo -e "${GREEN}pacman -Syu"
        sudo pacman -Syu
        printf "==================================================\n"

        if _is_installed snap; then
            _update_snap
        fi

        if  _is_installed brew; then
          _homebrew_update
        fi

        if  _is_installed flatpak; then
          _update_flatpak
        fi

        printf "==================================================\n"
        echo -e "${BOLD}DONE WITH UPDATE"
    fi
}
