source "${PIPE_PLUGIN}/colors.zsh"
source "${PIPE_PLUGIN}/docker.zsh"

function install-zsh-plugin() {
    plugin_link=$1
    plugin_name=$2

    if ! [[ -z "$1" || -z "$2" ]]; then
      git clone "$plugin_link" "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/"$plugin_name"
    else
      echo -e "${RED}" 'This command works with two params {plugin_link} and {plugin_name}'"${RESET}"
    fi
}

# PATHS
export PATH="$HOME"/.local/share/JetBrains/Toolbox/scripts:$PATH

# ALIASES
alias docker-cleanup="docker container prune -f && docker volumes prune"
