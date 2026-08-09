function _bluefin_is_supported {
	[[ -r "$OS_BLUEFIN_IMAGE_INFO" ]] &&
		grep -qE '"image-name"[[:space:]]*:[[:space:]]*"bluefin' "$OS_BLUEFIN_IMAGE_INFO"
}

function _bluefin_update {
	echo -e "${GREEN}ujust update\n"
	ujust update
}

function _bluefin_clean {
	echo -e "${GREEN}ujust clean-system\n"
	ujust clean-system
}

function _bluefin_manages_update_extras {
	return 0
}

function _bluefin_manages_clean_extras {
	return 0
}

PIPE_SYSTEM_UPDATE_HANDLERS+=(bluefin)
PIPE_SYSTEM_CLEAN_HANDLERS+=(bluefin)
