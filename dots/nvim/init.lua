pcall(require, "configs.options")
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

--  Load general configurations
pcall(require("configs.highlights").apply)
pcall(require, "configs.mappings")
pcall(require, "configs.gitblame")
pcall(require, "configs.terminal")

