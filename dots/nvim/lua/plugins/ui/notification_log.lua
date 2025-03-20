-- Notification log view
-- This provides a persistent log view for notifications

-- Don't return a plugin spec, just create the module directly
local M = {}

local log_buffer = nil
local log_window = nil
local namespace = vim.api.nvim_create_namespace("notification_log")
local max_lines = 1000 -- Maximum number of lines to keep in log

-- Function to create or show the log window
local function create_or_show_log()
  -- If window exists and is valid, just focus it
  if log_window and vim.api.nvim_win_is_valid(log_window) then
    vim.api.nvim_set_current_win(log_window)
    return
  end
  
  -- Create buffer if it doesn't exist
  if not log_buffer or not vim.api.nvim_buf_is_valid(log_buffer) then
    log_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(log_buffer, "Notification Log")
    vim.api.nvim_buf_set_option(log_buffer, "buftype", "nofile")
    vim.api.nvim_buf_set_option(log_buffer, "filetype", "notification_log")
    vim.api.nvim_buf_set_option(log_buffer, "swapfile", false)
    
    -- Set initial content
    vim.api.nvim_buf_set_lines(log_buffer, 0, -1, false, {
      "✦ Notification Log ✦",
      "Press q to close this window",
      "------------------------------",
      ""
    })
    
    -- Set up keymaps
    vim.api.nvim_buf_set_keymap(log_buffer, "n", "q", ":lua _G.notification_log_toggle()<CR>", {
      silent = true,
      noremap = true,
    })
    
    -- Set up autocmd to handle window close
    vim.api.nvim_create_autocmd("WinClosed", {
      pattern = "*",
      callback = function(ev)
        if log_window and tonumber(ev.match) == log_window then
          log_window = nil
        end
      end
    })
  end
  
  -- Calculate window dimensions
  local width = math.min(120, math.floor(vim.o.columns * 0.8))
  local height = math.min(20, math.floor(vim.o.lines * 0.6))
  
  -- Create window
  log_window = vim.api.nvim_open_win(log_buffer, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  
  -- Set window options
  vim.api.nvim_win_set_option(log_window, "wrap", true)
  vim.api.nvim_win_set_option(log_window, "number", false)
  vim.api.nvim_win_set_option(log_window, "cursorline", true)
  
  -- Move cursor to end of buffer
  vim.api.nvim_win_set_cursor(log_window, {vim.api.nvim_buf_line_count(log_buffer), 0})
end

-- Function to close the log window
local function close_log()
  if log_window and vim.api.nvim_win_is_valid(log_window) then
    vim.api.nvim_win_close(log_window, true)
    log_window = nil
  end
end

-- Function to toggle the log window
local function toggle_log()
  if log_window and vim.api.nvim_win_is_valid(log_window) then
    close_log()
  else
    create_or_show_log()
  end
end

-- Function to add a message to the log
local function add_to_log(msg, level)
  -- Ensure message doesn't contain newlines (fix the string replacement issue)
  if type(msg) == "string" then
    -- Replace newlines with spaces
    msg = msg:gsub("\n", " ")
  else
    msg = tostring(msg or "")
  end
  
  if not log_buffer or not vim.api.nvim_buf_is_valid(log_buffer) then
    log_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(log_buffer, "Notification Log")
    vim.api.nvim_buf_set_option(log_buffer, "buftype", "nofile")
    vim.api.nvim_buf_set_option(log_buffer, "swapfile", false)
    
    -- Set initial content
    vim.api.nvim_buf_set_lines(log_buffer, 0, -1, false, {
      "✦ Notification Log ✦",
      "Press q to close this window",
      "------------------------------",
      ""
    })
  end
  
  -- Get timestamp
  local timestamp = os.date("%H:%M:%S")
  
  -- Format level indicator
  local level_indicator = "INFO"
  if level == vim.log.levels.ERROR then
    level_indicator = "ERROR"
  elseif level == vim.log.levels.WARN then
    level_indicator = "WARN"
  elseif level == vim.log.levels.DEBUG then
    level_indicator = "DEBUG"
  end
  
  -- Format message
  local formatted_msg = string.format("[%s] [%s] %s", timestamp, level_indicator, msg)
  
  -- Add to buffer
  local line_count = vim.api.nvim_buf_line_count(log_buffer)
  vim.api.nvim_buf_set_lines(log_buffer, line_count, line_count, false, {formatted_msg})
  
  -- Trim log if needed
  if line_count > max_lines then
    vim.api.nvim_buf_set_lines(log_buffer, 4, line_count - max_lines + 4, false, {})
  end
  
  -- Scroll window if visible
  if log_window and vim.api.nvim_win_is_valid(log_window) then
    vim.api.nvim_win_set_cursor(log_window, {vim.api.nvim_buf_line_count(log_buffer), 0})
  end
end

-- Override notification function to also log to our custom log
local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
  -- Call original notify function
  orig_notify(msg, level, opts)
  
  -- Also add to our log
  add_to_log(msg, level)
end

-- Export functions to global for access from keymaps
_G.notification_log_toggle = toggle_log

-- Register command
vim.api.nvim_create_user_command("NotificationLogToggle", toggle_log, {})

-- Export module functions
M.toggle_log = toggle_log
M.add_to_log = add_to_log

return M 