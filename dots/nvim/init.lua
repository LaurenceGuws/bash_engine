-- Essential early-loading settings
-- These must be set before plugins or core modules load

-- 1. Disable netrw (required by nvim-tree to be set before it loads)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 2. Disable unused language providers before they're checked
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Lazy.nvim Bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load core modules
pcall(require, "core.options")  -- Load all non-essential options
pcall(require, "core.autocmds")
pcall(require, "core.keymaps")
pcall(require, "core.terminal")

-- Load plugins
require("lazy").setup({ import = "plugins" })