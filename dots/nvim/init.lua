-- Load core options first
pcall(require, "core.options")

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

-- Load plugins
require("lazy").setup({ import = "plugins" })

-- Load core modules 
pcall(require, "core.autocmds")
pcall(require, "core.keymaps")
pcall(require, "core.terminal")

-- Load utils
local utils = require("core.utils")

-- Add a command to reload configuration
vim.api.nvim_create_user_command("ConfigReload", utils.reload_config, { desc = "Reload nvim configuration" })

