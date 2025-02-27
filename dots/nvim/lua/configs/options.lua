local opt = vim.opt

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
opt.fillchars:append({ eob = " " })  -- Replace `~` with blank space

-- Enable persistent undo
opt.undofile = true  -- Keep undo history across sessions
opt.undodir = vim.fn.stdpath("data") .. "/undo" -- Set undo directory
vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.zig",
  callback = function()
    vim.bo.filetype = "zig"
  end,
})

return {}

