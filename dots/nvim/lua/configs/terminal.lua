-- Function to open a terminal with a command in a new buffer
function OpenTerminalBuffer(cmd, bufname)
  -- Check if buffer exists
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf) == bufname then
      -- Switch to existing buffer
      vim.api.nvim_set_current_buf(buf)
      return
    end
  end

  -- Otherwise, open a new buffer
  vim.cmd("enew")  -- Create a new buffer
  vim.cmd("file " .. bufname)  -- Set buffer name
  vim.cmd("terminal " .. cmd)  -- Run command in terminal
  vim.cmd("startinsert")  -- Enter insert mode for terminal
end

-- Key mappings for launching commands with descriptions
vim.api.nvim_set_keymap('n', '<leader>tk9', ':lua OpenTerminalBuffer("k9s", "K9s Dashboard")<CR>', { noremap = true, silent = true, desc = "K9s Dashboard (Kubernetes)" })
vim.api.nvim_set_keymap('n', '<leader>tbt', ':lua OpenTerminalBuffer("btop", "Btop System Monitor")<CR>', { noremap = true, silent = true, desc = "Btop System Monitor" })
vim.api.nvim_set_keymap('n', '<leader>tp', ':lua OpenTerminalBuffer("pacseek", "Pacseek Package Manager")<CR>', { noremap = true, silent = true, desc = "Pacseek Package Manager (Arch Linux)" })
vim.api.nvim_set_keymap('n', '<leader>tm', ':lua OpenTerminalBuffer("cmatrix", "Matrix Rain")<CR>', { noremap = true, silent = true, desc = "Matrix Rain (cmatrix)" })
vim.api.nvim_set_keymap('n', '<leader>tbs', ':lua OpenTerminalBuffer("bash -i -c browsh", "Browsh Web Browser")<CR>', { noremap = true, silent = true, desc = "Browsh Web Browser (Text-Based)" })
vim.api.nvim_set_keymap('n', '<leader>tgk', ':lua OpenTerminalBuffer("gk launchpad", "Game Launchpad")<CR>', { noremap = true, silent = true, desc = "Game Launchpad (gk)" })
vim.api.nvim_set_keymap('n', '<leader>tgl', ':lua OpenTerminalBuffer("lazygit", "LazyGit Interface")<CR>', { noremap = true, silent = true, desc = "LazyGit Interface (Git TUI)" })
vim.api.nvim_set_keymap('n', '<leader>t1d', ':lua OpenTerminalBuffer("bash -i -c 1doc", "1Doc Documentation")<CR>', { noremap = true, silent = true, desc = "1Doc Documentation" })
vim.api.nvim_set_keymap('n', '<leader>t1v', ':lua OpenTerminalBuffer("bash -i -c 1value", "1Value Viewer")<CR>', { noremap = true, silent = true, desc = "1Value Viewer (Structured Data)" })
vim.api.nvim_set_keymap('n', '<leader>tw', ':lua OpenTerminalBuffer("bash -i -c wiki_life", "Personal Wiki")<CR>', { noremap = true, silent = true, desc = "Personal Wiki (wiki_life)" })

-- Database UI (DBUI) Key Mappings (with Toggle on <leader>dt)
vim.api.nvim_set_keymap('n', '<leader>tdt', ':DBUIToggle<CR>', { noremap = true, silent = true, desc = "Toggle Database UI" })
vim.api.nvim_set_keymap('n', '<leader>tdu', ':DBUI<CR>', { noremap = true, silent = true, desc = "Open Database UI" })
vim.api.nvim_set_keymap('n', '<leader>tda', ':DBUIAddConnection<CR>', { noremap = true, silent = true, desc = "Add New Database Connection" })
vim.api.nvim_set_keymap('n', '<leader>tdf', ':DBUIFindBuffer<CR>', { noremap = true, silent = true, desc = "Find Database Buffer" })

