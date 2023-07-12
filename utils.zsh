function install-zsh-plugin {
	plugin_link=$1
	plugin_name=$2

	if [[ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/"$plugin_name" ]]; then
		echo -e "${YELLOW}This $plugin_name is already installed ${RESET}"
	else
		if ! [[ -z "$1" || -z "$2" ]]; then
			git clone "$plugin_link" "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/"$plugin_name"
		else
			echo -e "${RED}" 'This command works with two params {plugin_link} and {plugin_name}'"${RESET}"
		fi
	fi

}

function install-favorites {
	names=("zsh-autosuggestions", "zsh-syntax-highlighting")

	links=(
		"https://github.com/zsh-users/${names[0]}",
		"https://github.com/zsh-users/${names[1]}"
	)

	for ((i = 0; i <= ${#names}; i++)); do
		echo "${links[i]}"
		install-zsh-plugin ${links[i]} ${names[i]}
		omz plugin enable ${names[i]}
	done
}
