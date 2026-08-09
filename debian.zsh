function _debian_is_supported {
	[[ -f "$OS_DEBIAN" ]] && grep -qi "Debian" "$OS_DEBIAN"
}

function _debian_update {
	echo -e "${GREEN}apt update && upgrade\n"
	sudo apt update
	sudo apt upgrade -y
}

function _debian_clean {
	echo -e "${GREEN}apt clean autoclean autoremove\n"
	sudo apt autoclean
	sudo apt clean
	sudo apt autoremove -y
}

PIPE_SYSTEM_UPDATE_HANDLERS+=(debian)
PIPE_SYSTEM_CLEAN_HANDLERS+=(debian)
