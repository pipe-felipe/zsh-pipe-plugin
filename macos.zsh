function _macos_is_supported {
	[[ "$OSTYPE" == darwin* ]]
}

function _macos_update {
	# Package managers available on macOS are handled by the generic extras.
	return 0
}

function _macos_clean {
	return 0
}

PIPE_SYSTEM_UPDATE_HANDLERS+=(macos)
PIPE_SYSTEM_CLEAN_HANDLERS+=(macos)
