# zmodload zsh/zprof
export PATH=$PATH:/opt/homebrew/bin
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$HOME/.deno/bin:~$HOME/.dotfiles/scripts:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"

mkdir -p "$HOME/.zsh"
# prompt starship
eval "$(starship init zsh)"

# Increase function nesting limit for starship
export FUNCNEST=5000

# Enable vi mode
bindkey -v
# Reduce key delay for mode switching
export KEYTIMEOUT=1

# Fix backspace and delete in vi mode
bindkey -v '^?' backward-delete-char
bindkey -v '^H' backward-delete-char
bindkey -v '^[[3~' delete-char

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

# Prevent the command from being written to history before it's
# executed; save it to LASTHIST instead.  Write it to history
# in precmd.
#
# called before a history line is saved.  See zshmisc(1).
function zshaddhistory() {
  # Remove line continuations since otherwise a "\" will eventually
  # get written to history with no newline.
  LASTHIST=${1//\\$'\n'/}
  # Return value 2: "... the history line will be saved on the internal
  # history list, but not written to the history file".
  return 2
}

# zsh hook called before the prompt is printed.  See zshmisc(1).
function precmd() {
  # Write the last command if successful, using the history buffered by
  # zshaddhistory().
  if [[ $? == 0 && -n ${LASTHIST//[[:space:]\n]/} && -n $HISTFILE ]] ; then
    print -sr -- ${=${LASTHIST%%'\n'}}
  fi
}

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
HISTSIZE=5000000
SAVEHIST=$HISTSIZE

# HISTORY
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt SHARE_HISTORY             # Share history between all sessions.
# END HISTORY

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
source <(fzf --zsh)
export FZF_COMPLETION_DIR_COMMANDS="cd pushd rmdir tree"

alias pf="fzf --preview='bat {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"

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
alias wip='git add . && git commit -m "wip"'
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

function gl() {
  local lines=5
  if [[ "$1" =~ ^-[0-9]+$ ]]; then
    lines=${1#-}
    shift
  fi
  git log --pretty=format:"%C(yellow)%h %C(red)%ad %C(blue)%an%C(reset) %s %C(green)%D" --date=short --decorate -$lines "$@"
}

# ---- Node Version Manager (nvm) ----
# export NVM_DIR="$HOME/.nvm"
#   [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
#   [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


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

# Docker
alias docker='podman'
alias d='docker'

# Rust
export PATH=$PATH:"$HOME/.cargo/bin/"
export RUST_BACKTRACE=0



alias '??'='ghcs -t shell'
alias 'git?'='ghcs -t git'
alias 'explain'='gh copilot explain'

alias k='kubectl'
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

