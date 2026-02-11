# Bliss Neovim Config

A solid, maintainable, and fast Neovim configuration tailored for full-stack development.

## Features

- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) - Fast, stable, and modern.
- **LSP**: Native LSP with [Mason](https://github.com/williamboman/mason.nvim) for easy installation of servers.
- **Formatting**: [Conform.nvim](https://github.com/stevearc/conform.nvim) for reliable formatting.
- **Completion**: [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) with LuaSnip.
- **Explorer**: [Neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim) with git integration.
- **Fuzzy Finder**: [Telescope](https://github.com/nvim-telescope/telescope.nvim).
- **Git**: [Gitsigns](https://github.com/lewis6991/gitsigns.nvim) + LazyGit integration.
- **Theme**: [Catppuccin](https://github.com/catppuccin/nvim) (Mocha).
- **Terminal**: [ToggleTerm](https://github.com/akinsho/toggleterm.nvim).

> **Note**: `nvim-treesitter` is pinned to the `master` branch to ensure compatibility with existing plugins, as the `main` branch contains a breaking rewrite.


## Structure

```
~/.config/nvim/
├── init.lua            # Entry point
├── lua/
│   ├── config/         # Core configuration
│   │   ├── lazy.lua    # Plugin manager bootstrap
│   │   ├── options.lua # Vim options (clipboard, numbers, etc.)
│   │   ├── keymaps.lua # Global keymaps
│   │   └── autocmds.lua# Auto commands
│   └── plugins/        # Plugin specifications
│       ├── ui.lua      # Theme, Statusline, Notify, Dashboard
│       ├── editor.lua  # Neo-tree, Telescope, Gitsigns, Mini modules
│       ├── lsp.lua     # LSP, Mason, CMP
│       ├── formatting.lua # Conform (Formatting)
│       └── treesitter.lua # Syntax Highlighting
```

## Keymaps

Press `<space>` (Leader key) to see the Which-Key menu.

### Core
- `<space>e`: Toggle Explorer
- `<space>ff`: Find Files
- `<space>sg`: Live Grep
- `<space>b`: Buffer operations
- `<space>g`: Git operations
- `<C-\>`: Toggle Terminal

### LSP (when attached)
- `gd`: Go to definition
- `gr`: Go to references
- `K`: Hover documentation
- `<space>ca`: Code actions
- `<space>cr`: Rename
- `<space>cf`: Format

## Installation

1. Backup your existing `~/.config/nvim`.
2. This configuration is already placed in `~/.config/nvim`.
3. Open `nvim`. `lazy.nvim` will automatically bootstrap and install all plugins.
4. Run `:checkhealth` to verify the installation.
