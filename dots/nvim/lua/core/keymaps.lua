local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ----------------------------------------------------------------
-- Core Editor Operations
-- ----------------------------------------------------------------

-- Basic navigation and commands
map("n", ";", ":", { desc = "Enter Command Mode" })
map("i", "jk", "<ESC>", { desc = "Exit Insert Mode" })

-- Save File
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save File" })

-- Comment Line Toggle (Ctrl+/)
map("n", "<C-_>", "<Plug>(comment_toggle_linewise_current)", { desc = "Toggle Comment" })
map("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)", { desc = "Toggle Comment" })
map("v", "<C-_>", "<Plug>(comment_toggle_linewise_visual)", { desc = "Toggle Comment" })
map("v", "<C-/>", "<Plug>(comment_toggle_linewise_visual)", { desc = "Toggle Comment" })
map("i", "<C-_>", "<Esc><Plug>(comment_toggle_linewise_current)i", opts)
map("i", "<C-/>", "<Esc><Plug>(comment_toggle_linewise_current)i", opts)

map("n", "<C-\\>", "<cmd>lua require('snacks.terminal').toggle()<CR>", { desc = "Toggle Terminal" })



-- ----------------------------------------------------------------
-- Movement and Selection
-- ----------------------------------------------------------------

-- Word and Paragraph Navigation
map("n", "<C-Right>", "e", { desc = "Move to end of word" })
map("n", "<C-Left>", "b", { desc = "Move to beginning of word" })
map("n", "<C-Up>", "{", { desc = "Move up one paragraph" })
map("n", "<C-Down>", "}", { desc = "Move down one paragraph" })
map("i", "<C-Right>", "<C-o>e<Right>", { desc = "Move to end of word" })
map("i", "<C-Left>", "<C-o>b", { desc = "Move to beginning of word" })
map("i", "<C-Up>", "<C-o>{", { desc = "Move up one paragraph" })
map("i", "<C-Down>", "<C-o>}", { desc = "Move down one paragraph" })

-- HJKL alternatives for word/paragraph navigation
map("n", "<C-l>", "e", { desc = "Move to end of word" })
map("n", "<C-h>", "b", { desc = "Move to beginning of word" })
map("n", "<C-k>", "{", { desc = "Move up one paragraph" })
map("n", "<C-j>", "}", { desc = "Move down one paragraph" })
map("i", "<C-l>", "<C-o>e<Right>", { desc = "Move to end of word" })
map("i", "<C-h>", "<C-o>b", { desc = "Move to beginning of word" })
map("i", "<C-k>", "<C-o>{", { desc = "Move up one paragraph" })
map("i", "<C-j>", "<C-o>}", { desc = "Move down one paragraph" })

-- Selection (VS Code style)
map("n", "<S-Right>", "v<Right>", { desc = "Select right" })
map("n", "<S-Left>", "v<Left>", { desc = "Select left" })
map("n", "<S-Up>", "v<Up>", { desc = "Select up" })
map("n", "<S-Down>", "v<Down>", { desc = "Select down" })
map("i", "<S-Right>", "<Esc>v<Right>", { desc = "Select right" })
map("i", "<S-Left>", "<Esc>v<Left>", { desc = "Select left" })
map("i", "<S-Up>", "<Esc>v<Up>", { desc = "Select up" })
map("i", "<S-Down>", "<Esc>v<Down>", { desc = "Select down" })
map("v", "<S-Right>", "<Right>", { desc = "Extend selection right" })
map("v", "<S-Left>", "<Left>", { desc = "Extend selection left" })
map("v", "<S-Up>", "<Up>", { desc = "Extend selection up" })
map("v", "<S-Down>", "<Down>", { desc = "Extend selection down" })

-- Word Selection
map("n", "<C-S-Right>", "vE", { desc = "Select to end of word" })
map("n", "<C-S-Left>", "vB", { desc = "Select to beginning of word" })
map("i", "<C-S-Right>", "<Esc>vE", { desc = "Select to end of word" })
map("i", "<C-S-Left>", "<Esc>vB", { desc = "Select to beginning of word" })
map("v", "<C-S-Right>", "E", { desc = "Extend selection to end of word" })
map("v", "<C-S-Left>", "B", { desc = "Extend selection to beginning of word" })

-- ----------------------------------------------------------------
-- Editor Operations (VS Code Style)
-- ----------------------------------------------------------------

-- Selection
map("n", "<C-a>", "ggVG", { desc = "Select All" })
map("i", "<C-a>", "<Esc>ggVG", opts)
map("v", "<C-a>", "<Esc>ggVG", opts)

-- Copy/Cut/Paste
map("v", "<C-c>", [["+y]], { desc = "Copy" })
map("n", "<C-c>", [["+yy]], opts)
map("i", "<C-c>", "<Esc>", opts)

map("n", "<C-v>", [["+p]], { desc = "Paste" })
map("v", "<C-v>", [["+p]], opts)
map("i", "<C-v>", [[<C-r>+]], opts)

map("v", "<C-x>", [["+d]], { desc = "Cut" })
map("n", "<C-x>", [["+dd]], opts)
map("i", "<C-x>", [[<Esc>"+ddi]], opts)

-- Undo/Redo
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<C-o>u", opts)
map("v", "<C-z>", "<Esc>u", opts)

map("n", "<C-y>", "<C-r>", { desc = "Redo" })
map("i", "<C-y>", "<C-o><C-r>", opts)
map("v", "<C-y>", "<Esc><C-r>", opts)

-- Find
map("n", "<C-f>", "/", { desc = "Find in File" })
map("i", "<C-f>", "<Esc>/", opts)
map("v", "<C-f>", "<Esc>/", opts)

-- ----------------------------------------------------------------
-- Leader Key Mappings
-- ----------------------------------------------------------------

-- Terminal commands under toggle namespace
map("n", "<leader>tth", "<cmd>lua require('snacks.terminal').toggle()<CR>", { desc = "Horizontal Terminal" })
map("n", "<leader>ttf", "<cmd>lua require('snacks.terminal').toggle('bash')<CR>", { desc = "Floating Terminal" })

-- Notification history
map("n", "<leader>tn", ":NotificationLogToggle<CR>", { desc = "Show Notification History" })

-- Telescope/Fuzzy Finding
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<leader>fg", "<cmd>Telescope git_files<cr>", { desc = "Find Git Files" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find Help" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find Recent Files" })
map("n", "<leader>ft", "<cmd>Telescope live_grep<cr>", { desc = "Search Text" })

-- File Explorer
map("n", "<leader>e", "<cmd>lua require('snacks.explorer')()<CR>", { desc = "File Explorer" })

-- Theme/Colorscheme
map("n", "<leader>tc", "<cmd>Telescope colorscheme<cr>", { desc = "Theme Picker" })

-- Diagnostics
map("n", "<leader>td", "<cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })

map(
    "n",
    "<leader>tdi",
    "<cmd>lua vim.diagnostic.config({virtual_text = not vim.diagnostic.config().virtual_text})<CR>",
    { desc = "Toggle Inline Diagnostics" }
)
map(
    "n",
    "<leader>tds",
    "<cmd>lua vim.diagnostic.config({signs = not vim.diagnostic.config().signs})<CR>",
    { desc = "Toggle Diagnostic Signs" }
)

map("n", "<leader>tdc", "<cmd>lua require('core.lsp_utils').show_diagnostics_popup()<CR>", { desc = "Copy Buffer Diagnostics" })

map("n", "<leader>tdp", "<cmd>lua require('core.lsp_utils').show_diagnostics_popup({ scope = 'workspace' })<CR>", { desc = "Project Error List" })

-- Format
map("n", "<leader>tf", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", { desc = "Format Current Buffer" })
map("n", "<leader>tfs", "<cmd>ToggleFormatOnSave<CR>", { desc = "Toggle Format on Save" })
