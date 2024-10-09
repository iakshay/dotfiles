mkdir -p "$HOME/.zsh"
if [[ ! -a "$HOME/.zsh/fzf-git.sh" ]]; then
  git clone https://github.com/junegunn/fzf-git.sh "$HOME/.zsh/fzf-git.sh"
fi
fpath+=("$HOME/.zsh/fzf-git.sh/")

# autoload -Uz fzf-git
source ~/.zsh/fzf-git.sh/fzf-git.sh

# prompt starship
eval "$(starship init zsh)"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export EDITOR=nvim
export VISUAL=nvim
# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# Emacs style
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

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

# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"
# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --color=fg:-1,bg:-1,hl:#5f87af --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'
# export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git --exclude .pyenv --exclude node_modules"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git --exclude .pyenv --exclude node_modules"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}


show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ----- Bat (better cat) -----

export BAT_THEME=gruvbox-dark

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias neovim=nvim
alias vim=nvim
alias ls="eza --icons=always --git-ignore"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

export HOMEBREW_NO_INSTALL_CLEANUP=1
alias ~="cd ~"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
# alias cd="z"
alias reload='source ~/.zshrc'
alias ze='vim ~/.zshrc'
alias gam='git commit -a --amend --no-edit'
alias kb=karabiner_cli
export GOKU_EDN_CONFIG_FILE=$HOME/.config/karabiner/karabiner.edn
