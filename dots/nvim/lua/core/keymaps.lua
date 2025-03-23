local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ----------------------------------------------------------------
-- Core Keymaps
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

-- LSP Completions
map("i", "<C-Space>", "<cmd>lua require('cmp').complete()<CR>", { desc = "Toggle Completions" })

-- ----------------------------------------------------------------
-- Movement and Selection
-- ----------------------------------------------------------------

-- Ctrl + Movement for Fast Navigation
map("n", "<C-Right>", "e", { desc = "Move to end of word" })
map("n", "<C-Left>", "b", { desc = "Move to beginning of word" })
map("n", "<C-Up>", "{", { desc = "Move up one paragraph" })
map("n", "<C-Down>", "}", { desc = "Move down one paragraph" })
map("i", "<C-Right>", "<C-o>e<Right>", { desc = "Move to end of word" })
map("i", "<C-Left>", "<C-o>b", { desc = "Move to beginning of word" })
map("i", "<C-Up>", "<C-o>{", { desc = "Move up one paragraph" })
map("i", "<C-Down>", "<C-o>}", { desc = "Move down one paragraph" })

-- HJKL alternatives
map("n", "<C-l>", "e", { desc = "Move to end of word" })
map("n", "<C-h>", "b", { desc = "Move to beginning of word" })
map("n", "<C-k>", "{", { desc = "Move up one paragraph" })
map("n", "<C-j>", "}", { desc = "Move down one paragraph" })
map("i", "<C-l>", "<C-o>e<Right>", { desc = "Move to end of word" })
map("i", "<C-h>", "<C-o>b", { desc = "Move to beginning of word" })
map("i", "<C-k>", "<C-o>{", { desc = "Move up one paragraph" })
map("i", "<C-j>", "<C-o>}", { desc = "Move down one paragraph" })

-- Shift + Movement for Selection (VS Code style)
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

-- Shift+Ctrl combinations for word selection
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

-- Buffer Navigation (replaced with bufferline commands in the bufferline config)
-- map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next Buffer" })
-- map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
-- map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close Buffer" })

map("n", "<leader>e", function()
	local ok, explorer = pcall(require, "snacks.explorer")
	if ok then
		explorer()
	else
		vim.notify("Explorer not available", vim.log.levels.ERROR)
	end
end, { desc = "File Explorer" })

-- Terminal commands under toggle namespace
map("n", "<leader>tst", function()
	local ok, terminal = pcall(require, "snacks.terminal")
	if ok then
		terminal.toggle()
	else
		vim.notify("Terminal not available", vim.log.levels.ERROR)
	end
end, { desc = "Toggle Terminal" })

map("n", "<leader>tsf", function()
	local ok, terminal = pcall(require, "snacks.terminal")
	if ok then
		terminal.toggle({ style = "float" })
	else
		vim.notify("Terminal not available", vim.log.levels.ERROR)
	end
end, { desc = "Floating Terminal" })

map("n", "<leader>tss", function()
	local ok, terminal = pcall(require, "snacks.terminal")
	if ok then
		terminal.toggle({ style = "split" })
	else
		vim.notify("Terminal not available", vim.log.levels.ERROR)
	end
end, { desc = "Split Terminal" })

-- Additional TUI commands
map("n", "<leader>tm", function()
	vim.cmd("Mason")
end, { desc = "Mason" })

map("n", "<leader>tr", function()
	vim.cmd("MasonRegistry")
end, { desc = "Mason Registry" })

map("n", "<leader>tl", function()
	vim.cmd("Lazy")
end, { desc = "Lazy Plugin Manager" })

map("n", "<leader>tg", function()
	vim.cmd("Telescope live_grep")
end, { desc = "Live Grep" })

map("n", "<leader>td", function()
	vim.cmd("Telescope diagnostics")
end, { desc = "Diagnostics" })

map("n", "<leader>tp", function()
	-- Try to load project management plugin
	local has_project, project = pcall(require, "telescope")
	if has_project then
		vim.cmd("Telescope projects")
	else
		vim.notify("Project plugin not available", vim.log.levels.ERROR)
	end
end, { desc = "Projects" })

map("n", "<C-\\>", function()
	local ok, terminal = pcall(require, "snacks.terminal")
	if ok then
		terminal.toggle()
	else
		vim.notify("Terminal not available", vim.log.levels.ERROR)
	end
end, { desc = "Toggle Terminal" })

-- Telescope/Fuzzy Finding
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("i", "<C-p>", "<cmd>Telescope find_files<cr>", opts)
map("v", "<C-p>", "<cmd>Telescope find_files<cr>", opts)

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<leader>fg", "<cmd>Telescope git_files<cr>", { desc = "Find Git Files" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find Help" })
map("n", "<leader>/", "<cmd>Telescope live_grep<cr>", { desc = "Search Text" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find Recent Files" })

-- Toggle mappings
map("n", "<leader>tn", "<cmd>NotificationLogToggle<CR>", { desc = "Toggle Notification Log" })
map("n", "<leader>td", "<cmd>TroubleToggle document_diagnostics<CR>", { desc = "Toggle Document Diagnostics" })
map("n", "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<CR>", { desc = "Toggle Workspace Diagnostics" })
map("n", "<leader>tfs", "<cmd>ToggleFormatOnSave<CR>", { desc = "Toggle Format on Save" })

-- Theme/Colorscheme
map("n", "<leader>tc", function()
	require("plugins.ui.theme.theme_ui").open_theme_picker()
end, { desc = "Theme Picker" })

map("n", "<leader>uC", function()
	require("plugins.ui.theme.theme_ui").open_theme_picker()
end, { desc = "Colorschemes" })

-- Diagnostic configurations
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
map(
	"n",
	"<leader>tdu",
	"<cmd>lua vim.diagnostic.config({underline = not vim.diagnostic.config().underline})<CR>",
	{ desc = "Toggle Diagnostic Underlines" }
)
map("n", "<leader>tf", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", { desc = "Format Current Buffer" })

-- Diagnostic utils
map("n", "<leader>tdc", function()
	require("core.lsp_utils").show_diagnostics_popup()
end, { desc = "Copy Buffer Diagnostics" })
map("n", "<leader>tdp", function()
	require("core.lsp_utils").show_diagnostics_popup({ scope = "workspace" })
end, { desc = "Project Error List" })
