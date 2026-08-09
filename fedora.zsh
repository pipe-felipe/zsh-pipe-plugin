function _fedora_is_supported {
	[[ -f "$OS_FEDORA" ]]
}

function _fedora_update {
	echo -e "${GREEN}dnf upgrade\n"
	sudo dnf upgrade
}

function _fedora_clean {
	echo -e "${GREEN}dnf clean all\n"
	sudo dnf clean all
}

PIPE_SYSTEM_UPDATE_HANDLERS+=(fedora)
PIPE_SYSTEM_CLEAN_HANDLERS+=(fedora)
