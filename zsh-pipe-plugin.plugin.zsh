source "${PIPE_PLUGIN}/colors.zsh"

source "${PIPE_PLUGIN}/docker.zsh"
source "${PIPE_PLUGIN}/utils.zsh"
source "${PIPE_PLUGIN}/update-cleanup.zsh"

source "${PIPE_PLUGIN}/paths.zsh"
source "${PIPE_PLUGIN}/aliases.zsh"

if [[ ! -v PIPE_PLUGIN ]]; then
	echo -e "${RED} Put it on the top of .zshrc file"
	echo -e "export PIPE_PLUGIN="$HOME/.oh-my-zsh/custom/plugins/zsh-pipe-plugin/${RESET}""
fi