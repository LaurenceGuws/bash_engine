local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 🔹 General

-- 🔹 Command Mode
map("n", ";", ":", { desc = "Enter Command Mode" })
map("i", "jk", "<ESC>", { desc = "Exit Insert Mode" })

-- 🔹 Comment Line Toggle (Ctrl+/)
-- Using both common key representations for Ctrl+/ across different terminals
map("n", "<C-_>", "<Plug>(comment_toggle_linewise_current)", { desc = "Toggle Comment" })
map("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)", { desc = "Toggle Comment" })
map("v", "<C-_>", "<Plug>(comment_toggle_linewise_visual)", { desc = "Toggle Comment" })
map("v", "<C-/>", "<Plug>(comment_toggle_linewise_visual)", { desc = "Toggle Comment" })
map("i", "<C-_>", "<Esc><Plug>(comment_toggle_linewise_current)i", opts)
map("i", "<C-/>", "<Esc><Plug>(comment_toggle_linewise_current)i", opts)

-- 🔹 LSP Completions
map("i", "<C-Space>", "<cmd>lua require('cmp').complete()<CR>", { desc = "Toggle Completions" })

-- 🔹 Ctrl + Movement for Fast Navigation
-- Arrow keys
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

-- 🔹 Shift + Movement for Selection (VS Code style)
-- Arrow keys
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
-- HJKL alternatives (REMOVED)

-- 🔹 Shift+Ctrl combinations for word selection (VS Code style)
map("n", "<C-S-Right>", "vE", { desc = "Select to end of word" })
map("n", "<C-S-Left>", "vB", { desc = "Select to beginning of word" })
map("i", "<C-S-Right>", "<Esc>vE", { desc = "Select to end of word" })
map("i", "<C-S-Left>", "<Esc>vB", { desc = "Select to beginning of word" })
map("v", "<C-S-Right>", "E", { desc = "Extend selection to end of word" })
map("v", "<C-S-Left>", "B", { desc = "Extend selection to beginning of word" })

-- 🔹 LSP Keybindings
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to Definition" })
map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { desc = "Show References" })
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Hover Documentation" })
map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename Symbol" })
map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Code Actions" })

-- 🔹 Buffer Navigation (now under leader+b prefix)
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close Buffer" })

-- 🔹 File Explorer (consistent with which-key)
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle Explorer" })
map("n", "<leader>fe", "<cmd>NvimTreeFocus<CR>", { desc = "Focus Explorer" })

-- 🔹 Save File
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save File" })

-- 🔹 VS Code–Style Keybindings
map("n", "<C-a>", "ggVG", { desc = "Select All" })
map("i", "<C-a>", "<Esc>ggVG", opts)
map("v", "<C-a>", "<Esc>ggVG", opts)

map("v", "<C-c>", [["+y]], { desc = "Copy" })
map("n", "<C-c>", [["+yy]], opts)
map("i", "<C-c>", "<Esc>", opts)

map("n", "<C-v>", [["+p]], { desc = "Paste" })
map("v", "<C-v>", [["+p]], opts)
map("i", "<C-v>", [[<C-r>+]], opts)

map("v", "<C-x>", [["+d]], { desc = "Cut" })
map("n", "<C-x>", [["+dd]], opts)
map("i", "<C-x>", [[<Esc>"+ddi]], opts)

map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<C-o>u", opts)
map("v", "<C-z>", "<Esc>u", opts)

map("n", "<C-y>", "<C-r>", { desc = "Redo" })
map("i", "<C-y>", "<C-o><C-r>", opts)
map("v", "<C-y>", "<Esc><C-r>", opts)

map("n", "<C-f>", "/", { desc = "Find in File" })
map("i", "<C-f>", "<Esc>/", opts)
map("v", "<C-f>", "<Esc>/", opts)

-- 🔹 Telescope/Fuzzy Finding (reorganized to avoid overlaps)
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("i", "<C-p>", "<cmd>Telescope find_files<cr>", opts)
map("v", "<C-p>", "<cmd>Telescope find_files<cr>", opts)

-- 🔹 Reorganized Leader mappings for find operations
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<leader>fh", "<cmd>Telescope find_files hidden=true<cr>", { desc = "Find Hidden Files" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find Recent Files" })

-- 🔹 Buffer operations with consistent hierarchy
map("n", "<leader>fbb", "<cmd>FzfLua buffers<cr>", { desc = "Buffer List (FZF)" })
map("n", "<leader>fbu", "<cmd>Telescope buffers<cr>", { desc = "Telescope Buffers" })
map("n", "<leader>fbc", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search Current Buffer" })

-- 🔹 Grep operations with consistent hierarchy
map("n", "<leader>fgg", "<cmd>FzfLua live_grep<cr>", { desc = "Live Grep (FZF)" })
map("n", "<leader>fgf", "<cmd>Telescope git_files<cr>", { desc = "Find Git Files" })

-- 🔹 Markdown
map("n", "<leader>md", "<cmd>RenderMarkdownToggle<CR>", { desc = "Toggle Markdown Rendering" })
map("n", "<leader>mr", "<cmd>RenderMarkdownToggle<CR>", { desc = "Render Markdown" })


-- Key mappings for launching commands with descriptions
map('n', '<leader>tk9', ':lua OpenTerminalBuffer("k9s", "K9s Dashboard")<CR>', { noremap = true, silent = true, desc = "K9s Dashboard (Kubernetes)" })
map('n', '<leader>tbt', ':lua OpenTerminalBuffer("btop", "Btop System Monitor")<CR>', { noremap = true, silent = true, desc = "Btop System Monitor" })
map('n', '<leader>tpa', ':lua OpenTerminalBuffer("pacseek", "Pacseek Package Manager")<CR>', { noremap = true, silent = true, desc = "Pacseek Package Manager (Arch Linux)" })
map('n', '<leader>tm', ':lua OpenTerminalBuffer("cmatrix", "Matrix Rain")<CR>', { noremap = true, silent = true, desc = "Matrix Rain (cmatrix)" })
map('n', '<leader>tbs', ':lua OpenTerminalBuffer("bash -i -c browsh", "Browsh Web Browser")<CR>', { noremap = true, silent = true, desc = "Browsh Web Browser (Text-Based)" })
map('n', '<leader>tgk', ':lua OpenTerminalBuffer("gk launchpad", "Game Launchpad")<CR>', { noremap = true, silent = true, desc = "Game Launchpad (gk)" })
map('n', '<leader>tgl', ':lua OpenTerminalBuffer("lazygit", "LazyGit Interface")<CR>', { noremap = true, silent = true, desc = "LazyGit Interface (Git TUI)" })
map('n', '<leader>t1d', ':lua OpenTerminalBuffer("bash -i -c 1doc", "1Doc Documentation")<CR>', { noremap = true, silent = true, desc = "1Doc Documentation" })
map('n', '<leader>t1v', ':lua OpenTerminalBuffer("bash -i -c 1value", "1Value Viewer")<CR>', { noremap = true, silent = true, desc = "1Value Viewer (Structured Data)" })
map('n', '<leader>tw', ':lua OpenTerminalBuffer("bash -i -c wiki_life", "Personal Wiki")<CR>', { noremap = true, silent = true, desc = "Personal Wiki (wiki_life)" })
map('n', '<leader>tps', ':lua OpenTerminalBuffer("bash -i -c posting", "Posting (like Postman)")<CR>', { noremap = true, silent = true, desc = "Posting (like Postman)" })

-- Database UI (DBUI) Key Mappings (with Toggle on <leader>dt)
map('n', '<leader>dt', ':DBUIToggle<CR>', { noremap = true, silent = true, desc = "Toggle Database UI" })
map('n', '<leader>du', ':DBUI<CR>', { noremap = true, silent = true, desc = "Open Database UI" })
map('n', '<leader>da', ':DBUIAddConnection<CR>', { noremap = true, silent = true, desc = "Add New Database Connection" })
map('n', '<leader>df', ':DBUIFindBuffer<CR>', { noremap = true, silent = true, desc = "Find Database Buffer" })

-- 🔹 Diagnostic Toggles
map("n", "<leader>tt", "<cmd>TroubleToggle<CR>", { desc = "Toggle Trouble Panel" })
map("n", "<leader>td", "<cmd>TroubleToggle document_diagnostics<CR>", { desc = "Toggle Document Diagnostics" })
map("n", "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<CR>", { desc = "Toggle Workspace Diagnostics" })
map("n", "<leader>tdi", "<cmd>lua vim.diagnostic.config({virtual_text = not vim.diagnostic.config().virtual_text})<CR>", { desc = "Toggle Inline Diagnostics" })
map("n", "<leader>tds", "<cmd>lua vim.diagnostic.config({signs = not vim.diagnostic.config().signs})<CR>", { desc = "Toggle Diagnostic Signs" })
map("n", "<leader>tdu", "<cmd>lua vim.diagnostic.config({underline = not vim.diagnostic.config().underline})<CR>", { desc = "Toggle Diagnostic Underlines" })
map("n", "<leader>tf", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", { desc = "Format Current Buffer" })
map("n", "<leader>tfs", "<cmd>ToggleFormatOnSave<CR>", { desc = "Toggle Format on Save" })
