-- Explorer folder initialization module
-- Exports all explorer components in a structured way

return {
  -- Main file explorer (NvimTree) - now includes integrated context menu
  require("plugins.ui.exp.nvim-tree"),
  -- Educational minimal context menu implementation (kept for reference)
  -- require("plugins.ui.exp.minimal_context_menu"),
} 