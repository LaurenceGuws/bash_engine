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

-- Create autocommands for terminal buffers
local termgroup = vim.api.nvim_create_augroup("TerminalSettings", { clear = true })

-- Remove line numbers in terminal buffers
vim.api.nvim_create_autocmd({"TermOpen"}, {
  group = termgroup,
  callback = function()
    -- Disable line numbers
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    
    -- Additional terminal-specific settings
    vim.opt_local.signcolumn = "no"
    vim.opt_local.cursorline = false
    
    -- Automatically enter insert mode when entering a terminal buffer
    vim.cmd("startinsert")
  end
})

-- When entering a terminal buffer, start insert mode
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  pattern = "term://*",
  group = termgroup,
  callback = function()
    vim.cmd("startinsert")
  end
})

