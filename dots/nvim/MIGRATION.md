# Migration Guide: Neovim Configuration Restructuring

This document provides instructions for migrating from the old configuration structure to the new one.

## Overview

The restructuring aims to:
1. Create a more logical file organization
2. Group related plugins by functionality
3. Separate core Neovim settings from plugin configurations
4. Standardize naming conventions
5. Make the configuration more maintainable

## Migration Steps

### 1. Back Up Your Existing Configuration

```bash
# Create a backup of your current configuration
cp -r ~/.config/nvim ~/.config/nvim.backup
```

### 2. Apply New Directory Structure

```bash
# Replace these directories with the new structure
mv init.lua.new init.lua
mv lua/plugins/init.lua.new lua/plugins/init.lua
```

### 3. Test the New Configuration

```bash
# Start Neovim
nvim

# Inside Neovim, update all plugins
:Lazy sync
```

### 4. Troubleshooting

If you encounter issues:

1. Check for module loading errors in the Neovim logs:
   ```
   :lua vim.cmd('messages')
   ```

2. Validate specific module loading:
   ```
   :lua print(pcall(require, "module.path"))
   ```

3. Use the ConfigReload command to reload after fixes:
   ```
   :ConfigReload
   ```

### 5. Clean Up

Once everything is working properly:

```bash
# Optional: Remove old structure files that are no longer needed
rm -rf lua/configs
rm -rf lua/plugins/toolbox
rm -rf lua/plugins/theme
```

## Structure Mapping

| Old Path | New Path |
|----------|----------|
| `lua/configs/options.lua` | `lua/core/options.lua` |
| `lua/configs/mappings.lua` | `lua/core/keymaps.lua` |
| `lua/configs/terminal.lua` | `lua/core/terminal.lua` |
| `lua/plugins/toolbox/comment.lua` | `lua/plugins/coding/comment.lua` |
| `lua/plugins/toolbox/git.lua` | `lua/plugins/coding/git.lua` |
| `lua/plugins/toolbox/lsp/completions.lua` | `lua/plugins/coding/completion.lua` |
| `lua/plugins/toolbox/lsp/treesitter.lua` | `lua/plugins/coding/treesitter.lua` |
| `lua/plugins/ui/filetree.lua` | `lua/plugins/editor/explorer.lua` |
| `lua/plugins/toolbox/fzf.lua` | `lua/plugins/editor/fuzzy.lua` |
| `lua/plugins/markdown.lua` | `lua/plugins/editor/markdown.lua` |
| `lua/plugins/toolbox/which-key.lua` | `lua/plugins/editor/which-key.lua` |
| `lua/plugins/toolbox/ai/*` | `lua/plugins/integrations/ai/*` |
| `lua/plugins/toolbox/dadbod.lua` | `lua/plugins/integrations/dadbod.lua` |
| `lua/plugins/toolbox/kubectl.lua` | `lua/plugins/integrations/kubectl.lua` |
| `lua/plugins/theme/bufferline.lua` | `lua/plugins/ui/bufferline.lua` |
| `lua/plugins/theme/catppuccin.lua` | `lua/plugins/ui/colors.lua` |
| `lua/plugins/ui/mini-icons.lua` | `lua/plugins/ui/icons.lua` |
| `lua/plugins/ui/notify.lua` | `lua/plugins/ui/notify.lua` |
| `lua/plugins/theme/bar.lua` | `lua/plugins/ui/statusline.lua` |
| `lua/plugins/ui/noice.lua` | `lua/plugins/ui/ui-components.lua` |

## New Files

The restructuring also added new files:

1. `lua/core/autocmds.lua` - Centralizes all autocommands
2. `lua/core/utils.lua` - Adds utility functions 

## Future Maintenance

For future updates:
1. Add new plugins to their appropriate functional category
2. Keep core Neovim settings separate from plugin configurations
3. Use the provided structure for consistency 