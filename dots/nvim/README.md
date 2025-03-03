## Optional Tools

### Media Previews for FZF-Lua

For enhanced image previews in FZF-Lua, you can install additional tools:

1. **viu** - Terminal image viewer
   - Install with cargo: `cargo install viu`

2. **ueberzugpp** - Advanced terminal image viewer
   - Arch Linux: `pacman -S ueberzugpp`
   - Other systems: See [ueberzugpp installation](https://github.com/jstkdng/ueberzugpp)

Chafa is already installed and configured as the default image preview tool. 

### File Explorer

This configuration includes a VSCode-like file explorer with the following features:

- Familiar keybindings for file operations
- Git integration showing file status
- File icons and highlighting
- Intelligent tree navigation

**Keyboard Shortcuts:**
- `<leader>e` - Toggle file explorer
- `<leader>fe` - Focus file explorer

**While in the file explorer:**
- `a` - Create new file/directory
- `d` - Delete file/directory
- `r` - Rename file/directory
- `c`/`x`/`p` - Copy/cut/paste files
- `y` - Copy filename
- `Y` - Copy relative path
- `<C-y>` - Copy absolute path
- `<CR>` or `o` or `l` - Open file/directory
- `h` - Close directory
- `H` - Toggle hidden files
- `f` - Filter files
- `?` - Toggle help

### Keyboard Shortcuts

This configuration uses a hierarchical keybinding structure to avoid overlaps:

#### Help
- `<leader>?` - Show buffer-local keymaps (for context-specific commands)

#### Fuzzy Finding
- `<leader>f` - Find operations prefix
  - `<leader>ff` - Find files
  - `<leader>fh` - Find hidden files
  - `<leader>fr` - Recent files

  - **Buffer operations**
    - `<leader>fbb` - List buffers (FZF)
    - `<leader>fbu` - Telescope buffers
    - `<leader>fbc` - Search current buffer

  - **Grep operations**
    - `<leader>fgg` - Live grep search (FZF)
    - `<leader>fgf` - Find git files
    - `<leader>fgw` - Grep current word

#### Buffer Management
- `<leader>b` - Buffer operations prefix
  - `<leader>bn` - Next buffer
  - `<leader>bp` - Previous buffer
  - `<leader>bd` - Delete buffer

#### Markdown
- `<leader>m` - Markdown operations prefix
  - `<leader>md` - Toggle markdown rendering
  - `<leader>mr` - Render markdown

#### Comment Operations
- `<C-/>` or `<C-_>` - Toggle comment
- `gcc` - Comment line
- `gcb` - Comment block
- `<leader>gc` (visual mode) - Comment selection 

## Project Structure

This Neovim configuration follows a structured and modular approach:

```
lua/
├── core/                  # Core Neovim configuration
│   ├── autocmds.lua       # Autocommands
│   ├── keymaps.lua        # Global keymaps
│   ├── options.lua        # Neovim options
│   ├── terminal.lua       # Terminal configuration
│   └── utils.lua          # Helper utilities
│
└── plugins/               # Plugin configurations
    ├── coding/            # Development tools
    │   ├── comment.lua    # Code commenting
    │   ├── completion.lua # Auto-completion
    │   ├── git.lua        # Git integration
    │   ├── lsp/           # Language Server Protocol
    │   └── treesitter.lua # Syntax highlighting
    │
    ├── editor/            # Editor enhancements
    │   ├── explorer.lua   # File explorer
    │   ├── fuzzy.lua      # Fuzzy finding
    │   ├── markdown.lua   # Markdown support
    │   └── which-key.lua  # Keybinding help
    │
    ├── integrations/      # External integrations
    │   ├── ai/            # AI tools
    │   ├── dadbod.lua     # Database tools
    │   └── kubectl.lua    # Kubernetes integration
    │
    ├── ui/                # User Interface
    │   ├── bufferline.lua # Tab/buffer line
    │   ├── colors.lua     # Theme/colorscheme
    │   ├── icons.lua      # Icons
    │   ├── notify.lua     # Notifications
    │   ├── statusline.lua # Status line
    │   └── ui-components.lua # UI enhancements
    │
    └── init.lua           # Plugin loader
```

### Plugin Organization

Plugins are organized by functionality:

1. **Coding**: Tools for software development including LSP, completion, git
2. **Editor**: Core editor enhancements like file navigation, markdown support
3. **Integrations**: External tool integration like databases, Kubernetes
4. **UI**: Visual components and theme customization

### Core Configuration

Core settings are separated from plugins for clarity:

1. **Options**: Vim/Neovim settings
2. **Keymaps**: Global keyboard shortcuts
3. **Autocmds**: Automatic commands
4. **Terminal**: Terminal integration settings
5. **Utils**: Helper functions

## Customization

To customize this configuration:

1. Modify files in `lua/core/` for basic Neovim settings
2. Adjust plugin settings in their respective directories
3. Add new plugins by creating appropriate files in the relevant subdirectory
4. Run `:Lazy sync` after making changes to plugins

To reload the configuration without restarting Neovim, run `:ConfigReload` 