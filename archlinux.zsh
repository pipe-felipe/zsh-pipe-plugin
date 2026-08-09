function _archlinux_is_supported {
	[[ -f "$OS_ARCH" ]]
}

function private-is-arch-linux {
	if _archlinux_is_supported; then
		return 0
	else
		echo -e "${RED}You are not using Arch Linux${RESET}"
		echo -e "${YELLOW}This commands will not work${RESET}"
		return 1
	fi
}

function _archlinux_update {
	echo -e "${GREEN}pacman -Syu\n"
	sudo pacman -Syu
	echo -e "${GREEN}Updating AUR packages\n"
	sleep 1
	aur-update-all
}

function _archlinux_clean {
	echo -e "${GREEN}Removing orphaned packages\n"
	if pacman -Qdtq &>/dev/null; then
		pacman -Qdtq | while read -r pkg; do
			echo "Removing orphaned package: $pkg"
			sudo pacman -Rns --noconfirm "$pkg"
		done
	else
		echo "No orphaned packages to remove"
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
		local attempts=0
		while (( attempts < 3 )); do
			git clone --quiet "https://aur.archlinux.org/${pkg}.git" "$download_folder/$pkg" && break
			(( attempts++ ))
			echo -e "${RED}Failed to clone $pkg, retrying ($attempts/3)${RESET}"
			rm -rf "$download_folder/$pkg"
		done
	done

	for pkg in "${aur_packages[@]}"; do
		(
			if [[ ! -d "${download_folder}/${pkg}" ]]; then
				echo -e "${RED}Failed to clone $pkg, skipping${RESET}"
				return 1
			fi
			cd "${download_folder}/${pkg}" || return 1

			local epoch
			epoch=$(grep '^\s*epoch\s*=' .SRCINFO | awk '{print $3}')

			local pkgver
			pkgver=$(grep '^\s*pkgver\s*=' .SRCINFO | awk '{print $3}')

			local pkgrel
			pkgrel=$(grep '^\s*pkgrel\s*=' .SRCINFO | awk '{print $3}')

			local remote_version="${pkgver}-${pkgrel}"
			if [[ -n "$epoch" ]]; then
				remote_version="${epoch}:${remote_version}"
			fi

			local local_version
			local_version=$(pacman -Q "$pkg" | awk '{print $2}')

			if [[ $(vercmp "$remote_version" "$local_version") -gt 0 ]]; then
				echo -e "${GREEN}Updating $pkg from $local_version to $remote_version${RESET}"
				makepkg -sic
			else
				echo -e "${GREEN}$pkg is up to date ($local_version).${RESET}"
			fi
		)
	done

	rm -rf "$download_folder"
}

PIPE_SYSTEM_UPDATE_HANDLERS+=(archlinux)
PIPE_SYSTEM_CLEAN_HANDLERS+=(archlinux)
