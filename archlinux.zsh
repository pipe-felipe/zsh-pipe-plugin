function private-is-arch-linux {
	if [[ -f "$OS_ARCH" ]]; then
		return 0
	else
		echo -e "${RED}You are not using Arch Linux${RESET}"
		echo -e "${YELLOW}This commands will not work${RESET}"
		return 1
	fi
}

function aur-update-all {
	private-is-arch-linux || return 1

	local aur_packages=()
	while IFS= read -r line; do
		aur_packages+=("$line")
	done < <(pacman -Qqm)

	local download_folder="$HOME/Downloads/aur-update"
	mkdir -p "$download_folder"

	for pkg in "${aur_packages[@]}"; do
		echo -e "${YELLOW}Package to update: $pkg${RESET}"
		git clone "https://aur.archlinux.org/${pkg}.git" "$download_folder/$pkg" &
	done
	wait

	for pkg in "${aur_packages[@]}"; do
		cd "${download_folder}/${pkg}" || (echo -e "${RED} Failed to update AUR" && return 1)
		makepkg -sic
	done

	rm -rf "$download_folder"
}
