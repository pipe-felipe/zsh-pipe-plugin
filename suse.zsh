function _suse_is_supported {
	[[ -f "$OS_SUSE" ]]
}

function _suse_update {
	echo -e "${GREEN}zypper up\n"
	sudo zypper up
}

function _suse_clean {
	echo -e "${GREEN}zypper clean\n"
	sudo zypper clean
}

PIPE_SYSTEM_UPDATE_HANDLERS+=(suse)
PIPE_SYSTEM_CLEAN_HANDLERS+=(suse)
