mkdir -p "$HOME/.zsh"
if [[ ! -a "$HOME/.zsh/pure" ]]; then
  git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
fi
fpath+=("$HOME/.zsh/pure")

if [[ ! -a "$HOME/.zsh/z" ]]; then
  git clone https://github.com/rupa/z.git "$HOME/.zsh/z"
fi
source $HOME/.zsh/z/z.sh
autoload -U promptinit; promptinit
# prompt pure
eval "$(starship init zsh)"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


 export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export PATH=$PATH:~/.dotfiles/scripts
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# Set history file location
HISTFILE=~/.zsh_history

# Set the number of history lines to save
HISTSIZE=10000
SAVEHIST=10000

# Share history between terminals (tmux panes or new Zsh sessions)
setopt inc_append_history      # Immediately append history to the history file
setopt share_history           # Share history across sessions
setopt hist_ignore_all_dups     # Avoid duplicated entries

# Optional: Don't record commands that start with a space
setopt hist_ignore_space

# Optional: Automatically merge history from other sessions before each command
autoload -Uz add-zsh-hook
load_shared_history() {
  fc -R
}
add-zsh-hook preexec load_shared_history

# Function to manage virtual environments with subcommands
venv() {
    case "$1" in
        activate)
            # Look for a directory matching the *venv* pattern
            venv_dir=$(find . -type d -maxdepth 1 -name '*venv*' | head -n 1)

            if [[ -z "$venv_dir" ]]; then
                echo "Error: No virtual environment found in the current directory or subdirectories."
                return 1
            fi

            # Activate the virtual environment
            source "$venv_dir/bin/activate"
            echo "Activated virtual environment: $venv_dir"
            ;;
        
        deactivate)
            if [[ -z "$VIRTUAL_ENV" ]]; then
                echo "Error: No virtual environment is currently activated."
                return 1
            fi

            deactivate
            echo "Deactivated virtual environment: $VIRTUAL_ENV"
            ;;
        
        *)
            echo "Usage: venv {activate|deactivate}"
            return 1
            ;;
    esac
}


source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias neovim=nvim
alias vim=nvim
