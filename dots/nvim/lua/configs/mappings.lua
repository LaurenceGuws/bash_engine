local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 🔹 General

-- 🔹 Command Mode
map("n", ";", ":", { desc = "Enter Command Mode" })
map("i", "jk", "<ESC>", { desc = "Exit Insert Mode" })

-- 🔹 LSP Keybindings
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to Definition" })
map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { desc = "Show References" })
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Hover Documentation" })
map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename Symbol" })
map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Code Actions" })

-- 🔹 Buffer Navigation
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close Buffer" })
map({ "n", "v" }, "<leader>e", "<cmd>Explore<CR>", { desc = "Explorer" })

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

-- 🔹 Telescope Fuzzy Finder
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("i", "<C-p>", "<cmd>Telescope find_files<cr>", opts)
map("v", "<C-p>", "<cmd>Telescope find_files<cr>", opts)

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<leader>fh", "<cmd>Telescope find_files hidden=true<cr>", { desc = "Find Hidden Files" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find Buffers" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep Search" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find Recent Files" })
map("n", "<leader>fgf", "<cmd>Telescope git_files<cr>", { desc = "Find Git Files" })

