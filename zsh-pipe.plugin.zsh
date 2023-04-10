#!/usr/bin/env zsh

function install-zsh-plugin() {
    plugin_link=$1
    plugin_name=$2

    git clone $plugin_link ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin_name
}
