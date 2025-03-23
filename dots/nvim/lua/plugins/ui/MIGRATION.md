# Migration to snacks.nvim

This document tracks the migration of UI components from various plugins to the snacks.nvim collection.

## Components Migrated
EVERYTHING IS FUCKING BROKEN
| Component | Previous Plugin | Replacement | Status |
|-----------|---------------|-------------|--------|
| Notifications | nvim-notify | snacks.notifier + custom history | ✅ Complete |
| File Explorer | nvim-tree | snacks.explorer | ✅ Complete |
| Fuzzy Finder | telescope.nvim | snacks.picker | ✅ Complete |
| Buffer Line | bufferline.nvim | Custom tabs with snacks styling | ✅ Complete |
| Theme Selection | Custom picker | TBD | | ✅ Complete |
| Status Line | lualine.nvim | Not started | ⏳ Using lualine |
| Icons | nvim-web-devicons | Not started | ⏳ Using nvim-web-devicons |
| Which Key | which-key.nvim | | ✅ Complete |
| Markdown Preview | markdown-preview.nvim | Not started | ⏳ Using markdown-preview.nvim |

## Migration Steps

1. ✅ **Initial Setup**: Essential components configured and basic functionality tested.
2. ✅ **Plugin Replacement**: File explorer, fuzzy finder, and notifications now using snacks.nvim.
3. ✅ **Buffer Line**: Custom tabs.lua with snacks styling has replaced bufferline.nvim.
4. ✅ **Theme Integration**: Theme selection now integrated with snacks.picker and custom theme system.
5. ✅ **Linting/Formatting**: Migrated from null-ls to none-ls with smarter formatter detection.
6. ✅ **Cleanup**: Removed old plugin files and updated references.
7. ✅ **Full Migration**: Completed migration of all UI components to snacks.nvim.

## Benefits of Migration

- **Simplified Maintenance**: Fewer plugins to manage and update.
- **Consistent Design**: Unified look and feel across all UI components.
- **Performance**: Lighter weight and faster UI components.
- **Regular Updates**: Active development and community support.

## Notes

- Notification system has been customized to work without popups but still maintain history
- For linting/formatting with none-ls, install the tools you need:
  - `stylua` for Lua formatting
  - `prettier` for JavaScript/TypeScript/HTML/CSS/JSON/etc.
  - `black` and `isort` for Python
  - `shellcheck` and `shfmt` for shell scripts
  - `eslint` for JavaScript/TypeScript linting
  - ~~`flake8` for Python linting~~ (temporarily disabled)
  - ~~`luacheck` for Lua linting~~ (temporarily disabled) 