# NvimTree Advanced Context Menu with FZF

This implementation provides a modern, feature-rich context menu for NvimTree that integrates with FZF (Fuzzy Finder) to offer an elegant and customizable experience.

## Features

- 📋 Context-aware menu options based on node type (file/folder/git repo)
- 🎨 Styled with Catppuccin theme colors and Nerd Font icons
- 🔍 Advanced file search and grep operations
- 📝 Common file operations (open, copy, cut, paste, rename, delete)
- 🔄 Git integration for repositories (status, branches, commits)
- 📱 Mobile-friendly layout that repositions based on cursor location
- ⌨️ Both mouse (right-click) and keyboard (<leader>cm) support
- 🧠 Smart buffer-local mousemodel handling to prevent conflicts

## Implementation

The context menu is now directly integrated into the NvimTree configuration, which avoids potential loading issues and ensures proper functionality. This approach:

1. Registers the context menu function in the global scope `_G.nvim_tree_context_menu`
2. Maps right-click and <leader>cm to this global function during NvimTree setup
3. Sets `mousemodel=extend` locally for NvimTree buffers to prevent default popup menu

## Usage

After installation, simply right-click on any file or folder in NvimTree to open the context menu. You can also use the keyboard shortcut `<leader>cm` when your cursor is on a node.

### Available Actions

The menu dynamically changes based on the type of node (file, folder, git repo):

#### For All Items:
- Open, Split (vertical/horizontal), Open in Tab
- Rename, Delete, Cut, Copy
- Advanced search options (Find in Directory, Find Files)

#### For Folders:
- Expand/Collapse (with children options)
- Create File/Directory
  
#### For Files:
- Copy Path to clipboard
- Preview (with special handling for markdown and images)
  
#### For Git Repositories:
- Git Status (fzf-lua integration)
- Git Branches
- Git Commits

## Customization

To customize the menu, edit the `nvim-tree.lua` file. You can:

1. Find the `open_context_menu` function and modify the menu items
2. Change the appearance by modifying the `winopts` and `fzf_opts` tables
3. Add new actions by creating new functions and linking them to menu items

## How It Works

### Right-Click Handling

By default, Neovim has a built-in popup menu for right-clicks. Our implementation:

1. Buffers specific: Sets `mousemodel=extend` only for NvimTree buffers
2. Maps right-click to first position the cursor, then open our custom context menu
3. Uses the global function for reliability across different contexts

This approach ensures:
- No conflict with the default Neovim right-click behavior
- The custom context menu always works in NvimTree
- Regular right-click functionality is preserved outside of NvimTree

## Troubleshooting

If the context menu doesn't appear when right-clicking:

1. Check that fzf-lua is installed and working
2. Try using the keyboard shortcut <leader>cm instead
3. Restart Neovim to ensure all configuration is properly loaded

## Contributing

Feel free to enhance this plugin by:
- Adding more context-specific actions
- Improving the visual appearance
- Adding support for additional file types/operations 