function _neon_is_supported {
	[[ -f "$OS_NEON" ]] && grep -qi "neon" "$OS_NEON"
}

function _neon_update {
	echo -e "${GREEN}pkcon refresh and update\n"
	sudo pkcon refresh
	sudo pkcon update
}

function _neon_clean {
	echo -e "${GREEN}apt clean autoclean autoremove\n"
	sudo apt autoclean
	sudo apt clean
	sudo apt autoremove -y
}

PIPE_SYSTEM_UPDATE_HANDLERS+=(neon)
PIPE_SYSTEM_CLEAN_HANDLERS+=(neon)
