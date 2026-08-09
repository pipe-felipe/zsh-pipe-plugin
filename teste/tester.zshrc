# Minimal .zshrc baked into the test containers (see run.sh / containers/*).
# Mirrors the setup described in README.md "Configurations": PIPE_PLUGIN must
# be exported before the plugin file is sourced.
export PIPE_PLUGIN=/opt/zsh-pipe-plugin
source "${PIPE_PLUGIN}/zsh-pipe-plugin.plugin.zsh"
