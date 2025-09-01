# zmodload zsh/zprof
export PATH=$PATH:/opt/homebrew/bin
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$HOME/.deno/bin:~$HOME/.dotfiles/scripts:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"

mkdir -p "$HOME/.zsh"
# prompt starship
eval "$(starship init zsh)"

# Increase function nesting limit for starship
export FUNCNEST=2000

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

export EDITOR=$(which nvim)
export VISUAL=$(which nvim)
# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# Emacs style
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# Line navigation bindings
bindkey '^A' beginning-of-line  # Ctrl-A
bindkey '^E' end-of-line        # Ctrl-E
bindkey '^[[H' beginning-of-line   # Home key
bindkey '^[[F' end-of-line         # End key
bindkey '^[[1~' beginning-of-line  # Home key (alternative)
bindkey '^[[4~' end-of-line        # End key (alternative)

# Word navigation bindings
bindkey '^[f' forward-word    # Alt-f
bindkey '^[b' backward-word   # Alt-b

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
# autoload -Uz add-zsh-hook
# load_shared_history() {
#   fc -R
# }
# add-zsh-hook preexec load_shared_history

# Initialize zsh completion system with caching
autoload -Uz compinit
# Only rebuild completions if .zcompdump is older than .zshrc or doesn't exist
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Zsh completion configuration
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive completion
zstyle ':completion:*' menu select                         # Menu selection for completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # Colorized completion lists

# Load the menuselect keymap for completion menu
zmodload zsh/complist

# Ctrl-y bindings for completion and autosuggestions
bindkey -M menuselect '^y' .accept-line    # Accept completion in menu
bindkey '^y' autosuggest-accept            # Accept autosuggestion


# ---- FZF -----
# if [[ ! -a "$HOME/.zsh/fzf-git.sh" ]]; then
#   git clone https://github.com/junegunn/fzf-git.sh "$HOME/.zsh/fzf-git.sh"
# fi
# fpath+=("$HOME/.zsh/fzf-git.sh/")

# autoload -Uz fzf-git
# source ~/.zsh/fzf-git.sh/fzf-git.sh


# Set up fzf key bindings and fuzzy completion - lazy loaded
# _lazy_load_fzf() {
#     unset -f _lazy_load_fzf
#     eval "$(fzf --zsh)"
#     # Re-bind the key that triggered this
#     if [[ "$1" == "ctrl-t" ]]; then
#         zle fzf-file-widget
#     elif [[ "$1" == "ctrl-r" ]]; then
#         zle fzf-history-widget
#     elif [[ "$1" == "alt-c" ]]; then
#         zle fzf-cd-widget
#     fi
# }

# Create stub widgets that trigger lazy loading
# fzf-file-widget() { _lazy_load_fzf "ctrl-t" }
# fzf-history-widget() { _lazy_load_fzf "ctrl-r" }
# fzf-cd-widget() { _lazy_load_fzf "alt-c" }
#
# zle -N fzf-file-widget
# zle -N fzf-history-widget  
# zle -N fzf-cd-widget
#
# bindkey '^T' fzf-file-widget
# bindkey '^R' fzf-history-widget
# bindkey '^[c' fzf-cd-widget
# FZF_COPY_TO_CLIPBOARD_SPACE_SEPERATED_LIST="execute-silent(echo -n {+} | pbcopy)+abort"
# FZF_COPY_TO_CLIPBOARD_NEWLINE_SEPERATED_LIST="execute-silent(cat {+f} | perl -pe \"chomp if eof\" | pbcopy)+abort"
#
# FZF_DEFAULT_OPTS="--no-mouse --height 50% -1 --reverse --multi --inline-info --preview='[[ \\\$(file --mime (}) =~ binary 1] && echo (} is a binary file || (bat --style=numbers --color=always (} || cat (}) 2> /dev/null | head -300' --preview-window='right:hidden:wrap' --bind='f3:execute(bat --style=numbers {} || less -f (}),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-y:$FZF_COPY_TO_CLIPBOARD_NEWLINE_SEPERATED_LIST'"
# export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --color=fg:-1,bg:-1,hl:#5f87af --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'
#
# # -- Use fd instead of fzf --
#
# export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git --exclude .pyenv --exclude node_modules"
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git --exclude .pyenv --exclude node_modules"
#
# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
# _fzf_compgen_path() {
#   fd --hidden --exclude .git . "$1"
# }
#
# # Use fd to generate the list for directory completion
# _fzf_compgen_dir() {
#   fd --type=d --hidden --exclude .git . "$1"
# }
#
#
# show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
#
# export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
# export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
#
# # Advanced customization of fzf options via _fzf_comprun function
# # - The first argument to the function is the name of the command.
# # - You should make sure to pass the rest of the arguments to fzf.
# _fzf_comprun() {
#   local command=$1
#   shift
#
#   case "$command" in
#     cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
#     export|unset) fzf --preview "eval 'echo \\\${}'"         "$@" ;;
#     ssh)          fzf --preview 'dig {}'                   "$@" ;;
#     *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
#   esac
# }
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ----- Bat (better cat) -----
export BAT_THEME=gruvbox-dark

# ---- Zsh Autosuggestions ----
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ---- Zoxide (better cd) - lazy loaded ----
_lazy_load_zoxide() {
    unset -f z
    unset -f zi
    unset -f _lazy_load_zoxide
    eval "$(zoxide init zsh)"
    z "$@"
}
z() { _lazy_load_zoxide "$@" }
zi() { _lazy_load_zoxide "$@" }

# ---- Git Aliases and Functions ----
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
alias gwl='git worktree list'
function ge() {
  vim $(git rev-parse --show-toplevel)/.git/config
}

# Lazy load gh copilot for faster startup
_lazy_load_gh_copilot() {
    unset -f ghcs
    unset -f ghce
    unset -f _lazy_load_gh_copilot
    eval "$(gh copilot alias -- zsh)"
    ghcs "$@"
}
ghcs() { _lazy_load_gh_copilot "$@" }
ghce() { _lazy_load_gh_copilot "$@" }


# ---- Node Version Manager (nvm) ----
# export NVM_DIR="$HOME/.nvm"
#   [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
#   [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


export PATH="$PATH:/Users/akshay.aurora/.nvm/versions/node/v24.2.0/bin"
# ---- Python----
_lazy_load_pyenv() {
    unset -f pyenv
    unset -f _lazy_load_pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    pyenv "$@"
}
pyenv() { _lazy_load_pyenv "$@" }

# Automatically rename tmux windows to current directory
if [ -n "$TMUX" ]; then
  chpwd() {
    tmux rename-window "${PWD##*/}"
  }
  chpwd
elif [ -n "$WEZTERM_EXECUTABLE" ]; then
  # Update WezTerm tab title with current directory
  chpwd() {
    printf "\033]0;%s\007" "${PWD##*/}"
  }
  chpwd
fi


source ~/.zsh/internal.zsh
source ~/.dotfiles/scripts/worktree-manager.zsh
source ~/.dotfiles/scripts/cargo-worktree-target.zsh


# Rust
export PATH=$PATH:"$HOME/.cargo/bin/"
export RUST_BACKTRACE=full
export RUSTC_WRAPPER=$(which sccache)



alias '??'='ghcs -t shell'
alias 'git?'='ghcs -t git'
alias 'explain'='gh copilot explain'

alias k='kubectl'
alias ldo="lazydocker"
alias pt=parquet-tools
alias neovim=nvim
alias vim=nvim
alias ls="eza --icons=always"
alias lintfix="cargo clippy --all-targets --all-features --fix -- -D warnings"
alias lint="cargo clippy --all-targets --all-features -- -D warnings"
alias autoformat="cargo fmt --all"
alias af=autoformat
alias lf=lintfix
alias fmt=autoformat
alias fml="autoformat && lint"


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

