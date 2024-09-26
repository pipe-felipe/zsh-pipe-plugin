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
	git -C "$PIPE_PLUGIN" pull --rebase
}

function _add_comment {
  local file_path=$1
  local line_number=$2
  local action=$3
  local comment_symbol=$4

  if [ "$line_number" -lt 1 ] || [ "$line_number" -gt "$(wc -l < "$file_path")" ]; then
    echo "line number out of range"
    exit 1
  fi

  local lines=()
  while IFS= read -r line; do
    lines+=("$line")
  done < "$file_path"

  if [ "$action" = "add" ]; then
    if [[ ! "${lines[$line_number-1]}" =~ ^"$comment_symbol" ]]; then
      lines[line_number-1]="$comment_symbol${lines[$line_number-1]}"
    fi
  elif [ "$action" = "remove" ]; then
    if [[ "${lines[$line_number-1]}" =~ ^"$comment_symbol" ]]; then
      lines[line_number-1]="${lines[$line_number-1]#"$comment_symbol"}"
    fi
  else
    echo "the action must be 'add' or 'remove'."
    exit 1
  fi

  printf "%s\n" "${lines[@]}" > "$file_path"
}

function change-alacritty-theme {
  local theme=$1
  local alacritty_config="$HOME/.alacritty.toml"

  if [[ -f "$alacritty_config" ]]; then
    echo -e "${GREEN}Changing Alacritty theme to $theme...${RESET}"

		if [[ "$theme" == "dark" ]]; then
      _add_comment "$alacritty_config" 3 'add' '#'
      _add_comment "$alacritty_config" 4 'remove' '#'
    elif [[ "$theme" == "light" ]]; then
      _add_comment "$alacritty_config" 3 'remove' '#'
      _add_comment "$alacritty_config" 4 'add' '#'
    else
			echo -e "${RED}Invalid theme. Please choose between 'dark' or 'light'.${RESET}"
			return 1
    fi

    echo -e "${GREEN}Theme changed successfully.${RESET}"
  else
    echo -e "${RED}Alacritty configuration file not found at $alacritty_config.${RESET}"
  fi
}
