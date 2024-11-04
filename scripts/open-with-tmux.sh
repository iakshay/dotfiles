#!/bin/bash

PATH=$PATH:"/opt/homebrew/bin/"

# Check if a tmux session already exists
SESSION_NAME="0"
B=$(basename "$1")
D=$(dirname "$1")

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # Attach to the existing session and create a new window with the given path
    tmux new-window -a -t "$SESSION_NAME" -c "$D" "nvim '$B'"
else
    # Start a new tmux session with the window at the given path
    tmux new-session -s "$SESSION_NAME" -c "$D" "nvim '$B'"
fi
