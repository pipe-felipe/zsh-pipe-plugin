# ============================
# Returns with 0 means true
# Returns with 1 means false
# ============================

function _is_installed {
	if command -v "$1" >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

typeset -ga PIPE_SYSTEM_UPDATE_HANDLERS=()
typeset -ga PIPE_SYSTEM_CLEAN_HANDLERS=()

function _select_system_update_handler {
	local handler
	for handler in "${PIPE_SYSTEM_UPDATE_HANDLERS[@]}"; do
		if "_${handler}_is_supported"; then
			print -r -- "$handler"
			return 0
		fi
	done

	return 1
}

function _select_system_clean_handler {
	local handler
	for handler in "${PIPE_SYSTEM_CLEAN_HANDLERS[@]}"; do
		if "_${handler}_is_supported"; then
			print -r -- "$handler"
			return 0
		fi
	done

	return 1
}

function _handler_manages_update_extras {
	local handler_function="_${1}_manages_update_extras"
	(( $+functions[$handler_function] )) || return 1
	"$handler_function"
}

function _handler_manages_clean_extras {
	local handler_function="_${1}_manages_clean_extras"
	(( $+functions[$handler_function] )) || return 1
	"$handler_function"
}

function _homebrew_update {
	echo -e "${YELLOW}brew update\n"
	brew update

	echo -e "${YELLOW}brew upgrade\n"
	brew upgrade
	printf "\n"
}

function _update_snap {
	echo -e "${YELLOW}snap refresh \n"
	sudo snap refresh
	printf "\n"
}

function _update_flatpak {
	echo -e "${YELLOW}flatpak update"
	flatpak update -y
	printf "\n"
}

function _cleanup_homebrew {
	echo -e "${YELLOW}brew cleanup\n"
	brew cleanup

	echo -e "${YELLOW}brew autoremove\n"
	brew autoremove
	printf "\n"
}

function _cleanup_flatpak {
	echo -e "${YELLOW}flatpak --unused\n"
	flatpak uninstall --unused -y
	printf "\n"
}

function update {
	echo -e "${BLUE}${BOLD}\nSYSTEM UPDATE ${RESET}"
	printf "\n"

	local handler
	handler=$(_select_system_update_handler)
	if [[ -n "$handler" ]]; then
		"_${handler}_update"
	fi

	if [[ -z "$handler" ]] || ! _handler_manages_update_extras "$handler"; then
		if _is_installed snap; then _update_snap; fi
		if _is_installed brew; then _homebrew_update; fi
		if _is_installed flatpak; then _update_flatpak; fi
	fi

	printf "==================================================\n"
	echo -e "${BOLD}DONE WITH UPDATE"
}

function clean {
	echo -e "${BLUE}${BOLD}\nSYSTEM CLEANUP ${RESET}"
	printf "\n"

	local handler
	handler=$(_select_system_clean_handler)
	if [[ -n "$handler" ]]; then
		"_${handler}_clean"
	fi

	if [[ -z "$handler" ]] || ! _handler_manages_clean_extras "$handler"; then
		if _is_installed brew; then _cleanup_homebrew; fi
		if _is_installed flatpak; then _cleanup_flatpak; fi
	fi

	printf "==================================================\n"
	echo -e "${BOLD}DONE WITH CLEANUP"
}
