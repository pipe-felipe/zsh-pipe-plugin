source "${PIPE_PLUGIN}/colors.zsh"
source "${PIPE_PLUGIN}/variables.zsh"

source "${PIPE_PLUGIN}/docker.zsh"
source "${PIPE_PLUGIN}/nvidia.zsh"
source "${PIPE_PLUGIN}/utils.zsh"
source "${PIPE_PLUGIN}/update-cleanup.zsh"

# ============================
# System Handlers

# Bluefin
source "${PIPE_PLUGIN}/bluefin.zsh"

# KDE Neon
source "${PIPE_PLUGIN}/neon.zsh"

# Ubuntu
source "${PIPE_PLUGIN}/ubuntu.zsh"

# Debian
source "${PIPE_PLUGIN}/debian.zsh"

# Fedora
source "${PIPE_PLUGIN}/fedora.zsh"

# openSUSE
source "${PIPE_PLUGIN}/suse.zsh"

# Arch Linux
source "${PIPE_PLUGIN}/archlinux.zsh"

# macOS
source "${PIPE_PLUGIN}/macos.zsh"

# ============================

source "${PIPE_PLUGIN}/paths.zsh"
source "${PIPE_PLUGIN}/aliases.zsh"



if [[ -v EXTENDED_FUNCTIONS_FOLDER ]]; then
		source "${EXTENDED_FUNCTIONS_FOLDER}/main.zsh"
fi

if [[ ! -v PIPE_PLUGIN ]]; then
	echo -e "${RED}${BOLD}Put it on the top of .zshrc file${RESET}"
	echo -e "${YELLOW}export PIPE_PLUGIN=""$HOME"/.oh-my-zsh/custom/plugins/zsh-pipe-plugin/"${RESET}"""
fi
