# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files for various development tools and applications. It uses GNU Stow for symbolic link management to deploy configurations to their proper locations.

## Core Architecture

The repository is organized with each tool having its own directory that mirrors the target directory structure:

- **neovim/**: Lua-based Neovim configuration with modular plugin system
- **tmux/**: Terminal multiplexer configuration with custom key bindings
- **zsh/**: Shell configuration with Starship prompt
- **vscode/**: VS Code/Cursor settings, keybindings, and extensions
- **git/**: Git configuration and aliases
- **scripts/**: Utility scripts for tmux integration and browser automation
- **wezterm/**: Terminal emulator configuration
- **starship/**: Cross-shell prompt configuration

## Common Commands

### Setup and Installation
```bash
# Clone and set up dotfiles
git clone git@github.com:iakshay/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow git neovim tmux wezterm zsh claude
```


```

### Managing Configurations
```bash
# Add new configurations with stow
stow <package-name>

# Remove configurations
stow -D <package-name>

# Restow (useful after updates)
stow -R <package-name>
```

## Configuration Architecture

### Neovim Configuration
- **init.lua**: Main configuration entry point with core settings
- **lua/plugins/**: Modular plugin configurations organized by functionality
  - LSP, autocompletion, formatting, linting, debugging
  - Git integration, telescope, treesitter, UI enhancements
  - AI tools, testing, markdown, and specialized workflows
- Uses lazy.nvim for plugin management
- Leader key set to space

### Tmux Configuration
- Prefix key: `Ctrl-a` (instead of default `Ctrl-b`)
- Custom key bindings for window/pane management
- Integration with current working directory for new windows/panes
- Reload configuration with `prefix + r`

### Shell Configuration (Zsh)
- Starship prompt integration
- Homebrew path configuration
- Nvim as default editor
- Command line editing with `Ctrl-x-e`

### Utility Scripts
- **open-with-tmux.sh**: Opens files in Neovim within tmux sessions
- **show-tmux-popup.sh**: Creates tmux popup windows
- **chrome-search.sh**: Browser automation for search

## Key Integrations

- **Tmux + Neovim**: Seamless terminal workflow with session management
- **Starship**: Consistent prompt across shell environments  
- **VS Code/Cursor**: Shared configuration between editors
- **Git**: Custom aliases and configurations for development workflow
- **Stow**: Declarative symlink management for all configurations
