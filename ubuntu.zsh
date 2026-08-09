function _ubuntu_is_supported {
	[[ -f "$OS_UBUNTU" ]] && grep -qi "ubuntu" "$OS_UBUNTU"
}

function _ubuntu_update {
	echo -e "${GREEN}apt update && upgrade\n"
	sudo apt update
	sudo apt upgrade -y
}

function _ubuntu_clean {
	echo -e "${GREEN}apt clean autoclean autoremove\n"
	sudo apt autoclean
	sudo apt clean
	sudo apt autoremove -y
}

PIPE_SYSTEM_UPDATE_HANDLERS+=(ubuntu)
PIPE_SYSTEM_CLEAN_HANDLERS+=(ubuntu)
