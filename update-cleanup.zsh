readonly OS_ARCH=/etc/arch-release
readonly OS_FEDORA=/etc/fedora-release
readonly OS_UBUNTU=/etc/os-release
readonly OS_SUSE=/usr/etc/SUSE-brand
readonly OS_NEON=/etc/os-release
readonly OS_DEBIAN=/etc/os-release

# 0 = true | 1 = false

function _is_installed {
	if command -v "$1" >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

function _homebrew_update {
	echo -e "${YELLOW}brew update\n"
	brew update

	echo -e "${YELLOW}brew upgrade\n"
	brew upgrade
	printf "\n"
}

function _update_snap {
	echo -e "${YELLOW}snap refresh \n"
	sudo snap refresh
	printf "\n"
}

function _update_flatpak {
	echo -e "${YELLOW}flatpak update"
	flatpak update -y
	printf "\n"
}

function _os_update {
	if test -f "$OS_FEDORA"; then
		echo -e "${GREEN}dnf upgrade\n"
		sudo dnf upgrade
	fi

	if test -f "$OS_ARCH"; then
		echo -e "${GREEN}pacman -Syu\n"
		sudo pacman -Syu
	fi

	if ([[ -f "$OS_UBUNTU" ]] && grep -qi "ubuntu" "$OS_UBUNTU") ||
		([[ -f "$OS_DEBIAN" ]] && grep -qi "Debian" "$OS_DEBIAN"); then
		if ! grep -qi "neon" "$OS_UBUNTU"; then
			echo -e "${GREEN}apt update && upgrade\n"
			sudo apt update
			sudo apt upgrade -y
		fi
	fi

	if test -f "$OS_SUSE"; then
		echo -e "${GREEN}zypper up\n"
		sudo zypper up
	fi

	if [[ -f "$OS_NEON" ]] && grep -qi "neon" "$OS_NEON"; then
		echo -e "${GREEN}pkcon refresh and update\n"
		sudo pkcon refresh
		sudo pkcon update
	fi
}

function _cleanup_homebrew {
	echo -e "${YELLOW}brew cleanup\n"
	brew cleanup

	echo -e "${YELLOW}brew autoremove\n"
	brew autoremove
	printf "\n"
}

function _cleanup_flatpak {
	echo -e "${YELLOW}flatpak --unused\n"
	flatpak uninstall --unused -y
	printf "\n"
}

function _os_clean {
	if test -f "$OS_FEDORA"; then
		echo -e "${GREEN}dnf clean all\n"
		sudo dnf clean all
	fi

	if test -f "$OS_ARCH"; then
		echo -e "${GREEN}-Rsn pacman -Qtdq\n"
		sudo pacman -Rns "$(pacman -Qtdq)"
	fi

	if [[ -f "$OS_UBUNTU" || -f "$OS_NEON" || -f "$OS_DEBIAN" ]]; then
		if grep -qi "ubuntu" "$OS_UBUNTU" || grep -qi "neon" "$OS_NEON" || grep -qi "Debian" "$OS_DEBIAN"; then
			echo -e "${GREEN}apt clean autoclean autoremove\n"
			sudo apt autoclean
			sudo apt clean
			sudo apt autoremove -y
		fi
	fi

	if test -f "$OS_SUSE"; then
		echo -e "${GREEN}zypper clean\n"
		sudo zypper clean
	fi
}

function update {
	echo -e "${BLUE}${BOLD}\nSYSTEM UPDATE ${RESET}"
	printf "\n"

	_os_update

	if _is_installed snap; then _update_snap; fi
	if _is_installed brew; then _homebrew_update; fi
	if _is_installed flatpak; then _update_flatpak; fi

	printf "==================================================\n"
	echo -e "${BOLD}DONE WITH UPDATE"
}

function clean {
	echo -e "${BLUE}${BOLD}\nSYSTEM CLEANUP ${RESET}"
	printf "\n"

	_os_clean

	if _is_installed brew; then _cleanup_homebrew; fi
	if _is_installed flatpak; then _cleanup_flatpak; fi

	printf "==================================================\n"
	echo -e "${BOLD}DONE WITH CLEANUP"
}
