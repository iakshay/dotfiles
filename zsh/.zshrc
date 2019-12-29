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
prompt pure
