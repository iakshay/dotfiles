#!/bin/bash

# https://blog.meain.io/2020/tmux-flating-scratch-terminal/
if [ "$(tmux display-message -p -F "#{session_name}")" = "popup" ];then
    tmux detach-client
else
    tmux popup -E $HOME/.dotfiles/scripts/show-tmux-popup.sh
fi