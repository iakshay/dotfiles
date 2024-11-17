#!/bin/bash

export PATH=$PATH:/opt/homebrew/bin
# https://willhbr.net/2023/02/07/dismissable-popup-shell-in-tmux/
session="popup"

if ! tmux has -t "$session" 2> /dev/null; then
  session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}')"
  tmux set-option -s -t "$session_id" key-table popup
  tmux set-option -s -t "$session_id" status off
  tmux set-option -s -t "$session_id" prefix None
  session="$session_id"
fi

tmux attach -t "$session"

# tmux attach -t popup || tmux new -s popup
