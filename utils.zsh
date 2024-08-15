function install-zsh-plugin {
	local plugin_link=$1
	local plugin_name=$2

	local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"

	if [[ -d "$plugin_dir" ]]; then
		echo -e "${YELLOW}This $plugin_name is already installed.${RESET}"
	else
		if [[ -n "$plugin_link" && -n "$plugin_name" ]]; then
			git clone "$plugin_link" "$plugin_dir"
			echo -e "Plugin '$plugin_name' has been installed."
		else
			echo -e "${RED}This command requires two parameters: {plugin_link} and {plugin_name}.${RESET}"
		fi
	fi
}

function install-favorites {
	local names=("zsh-autosuggestions" "zsh-syntax-highlighting")
	local links=("https://github.com/zsh-users/zsh-autosuggestions" "https://github.com/zsh-users/zsh-syntax-highlighting")

	for ((i = 1; i <= ${#names[@]}; i++)); do
		install-zsh-plugin "${links[i]}" "${names[i]}"
	done
}

function update-this {
	cd "$PIPE_PLUGIN" && ls
}
