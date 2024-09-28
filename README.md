Dotfiles
========

This is my collection of [configuration files](http://dotfiles.github.io/).

Usage
-----

Pull the repository, and then create the symbolic links [using GNU
stow](https://www.gnu.org/software/stow/).

```bash
git clone git@github.com:iakshay/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow git neovim tmux wezterm iterm2 zsh fish
```

VSCode
----

Remove existing configurations:

```bash
rm -rf "$HOME/Library/Application Support/Code/User"
rm -rf "$HOME/Library/Application Support/Cursor/User"
```

Copy shared configuration and install extensions

```bash
BASE_PATH="$HOME/Library/Application Support"
APPS=("Cursor" "Code")
FILES=("keybindings.json" "settings.json" "tasks.json" "snippets")

for app in "${APPS[@]}"; do
    target_directory="$BASE_PATH/$app/User"
    mkdir -p $target_directory
    for file in "${FILES[@]}"; do
        # Check if the file exists
        if [[ -e "$file" ]]; then
            ln -s "$(realpath "$file")" "$target_directory/$(basename "$file")"
            echo "Created symlink for $file in $target_directory"
        else
            echo "File $file does not exist."
        fi
    done

    # Loop through each line in the file
    while IFS= read -r extension; do
        # Run the install command for each extension
        CMD=$($app| awk '{print tolower($0)}')
        $CMD --install-extension "$extension"
    done < extensions
done
```

- Export profiles in `profiles` and share everything except extensions.
