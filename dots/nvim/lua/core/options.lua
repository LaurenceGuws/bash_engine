local opt = vim.opt

-- 1. Essential early-loading settings
-- These must be set before plugins load

vim.g.ansi_colors_enabled = true
vim.opt.scrolloff = 2
vim.opt.confirm = true

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Disable netrw (required by nvim-tree to be set before it loads)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable unused language providers before they're checked
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Set leader key
vim.g.mapleader = " "

-- General settings
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.swapfile = false
opt.backup = false

-- Indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

-- UI Tweaks
opt.termguicolors = true
opt.signcolumn = "yes"
opt.fillchars:append({ eob = " " }) -- Replace `~` with blank space

-- Enable persistent undo
opt.undofile = true -- Keep undo history across sessions
opt.undodir = vim.fn.stdpath("data") .. "/undo" -- Set undo directory

return {}
