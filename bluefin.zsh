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

PIPE_SYSTEM_UPDATE_HANDLERS+=(bluefin)
PIPE_SYSTEM_CLEAN_HANDLERS+=(bluefin)
