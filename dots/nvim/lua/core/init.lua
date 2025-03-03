-- Core initialization module
-- Handles all essential Neovim settings and loads core modules

-- 1. Essential early-loading settings
-- These must be set before plugins load

-- Disable netrw (required by nvim-tree to be set before it loads)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable unused language providers before they're checked
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Set leader key
vim.g.mapleader = " "

-- 2. Load other core modules
local function load_core()
  -- Load all non-essential options
  pcall(require, "core.options")  
  pcall(require, "core.autocmds")
  pcall(require, "core.keymaps")
  pcall(require, "core.terminal")
end

load_core()

-- Load plugins through Lazy.nvim
require("lazy").setup({ import = "plugins" })
return {
  -- Export functions if we need to access them elsewhere
  load_core = load_core,
} 