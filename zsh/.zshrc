# zmodload zsh/zprof
export PATH=$PATH:/opt/homebrew/bin
mkdir -p "$HOME/.zsh"
# if [[ ! -a "$HOME/.zsh/fzf-git.sh" ]]; then
#   git clone https://github.com/junegunn/fzf-git.sh "$HOME/.zsh/fzf-git.sh"
# fi
# fpath+=("$HOME/.zsh/fzf-git.sh/")

# autoload -Uz fzf-git
# source ~/.zsh/fzf-git.sh/fzf-git.sh

# prompt starship
eval "$(starship init zsh)"

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

export EDITOR=nvim
export VISUAL=nvim
# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# Emacs style
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# if [[ ! -a "$HOME/.zsh-nvm" ]]; then
#   "Installing zsh-nvm"
#   git clone https://github.com/lukechilds/zsh-nvm.git ~/.zsh-nvm
# fi
# export NVM_LAZY_LOAD=true
# source ~/.zsh-nvm/zsh-nvm.plugin.zsh
# export NVM_DIR="$HOME/.nvm"
#   [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
#   [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
export PATH=$PATH:/Users/akshayaurora/.nvm/versions/node/v18.20.4/bin
#
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


# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"
FZF_COPY_TO_CLIPBOARD_SPACE_SEPERATED_LIST="execute-silent(echo -n {+} | pbcopy)+abort"
FZF_COPY_TO_CLIPBOARD_NEWLINE_SEPERATED_LIST="execute-silent(cat {+f} | perl -pe \"chomp if eof\" | pbcopy)+abort"

FZF_DEFAULT_OPTS="--no-mouse --height 50% -1 --reverse --multi --inline-info --preview='[[ \$(file --mime (}) =~ binary 1] && echo (} is a binary file || (bat --style=numbers --color=always (} || cat (}) 2> /dev/null | head -300' --preview-window='right:hidden:wrap' --bind='f3:execute(bat --style=numbers {} || less -f (}),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-y:$FZF_COPY_TO_CLIPBOARD_NEWLINE_SEPERATED_LIST'"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --color=fg:-1,bg:-1,hl:#5f87af --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'

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
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ----- Bat (better cat) -----

export BAT_THEME=gruvbox-dark

# source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh



alias neovim=nvim
alias vim=nvim
alias ls="eza --icons=always"

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

alias kb=karabiner_cli
alias lg=lazygit
export GOKU_EDN_CONFIG_FILE=$HOME/.config/karabiner/karabiner.edn

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# eval "$(direnv hook zsh)"

# Run the function for the initial shell startup directory
# zprof
#
function gnb() {
  if [[ -z "$1" ]]; then
    echo "Usage: gnb <branch-name>"
    return 1
  fi

  local branch_name=$1
  local base_branch=${2:-main}

  echo "Fetching latest changes from origin/$base_branch"
  git fetch origin $base_branch || { echo "Failed to fetch from remote."; return 1; }

  echo "Creating and switching to new branch: $branch_name"
  git checkout -b "$branch_name" origin/$base_branch || { echo "Failed to create branch $branch_name."; return 1; }

  echo "Branch '$branch_name' created and switched successfully."
}
alias gpush='git pu || git push origin $(git rev-parse --abbrev-ref HEAD)'
alias gs='git status'
alias gc='git checkout'
alias gd='git diff'
alias gam='git commit -a --amend --no-edit'
alias ge="vim $(git rev-parse --show-toplevel)/.git/config"
alias k='kubectl'

eval "~/.dotfiles/zsh/internal.zsh"

