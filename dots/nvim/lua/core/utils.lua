-- Utility functions for Neovim configuration

local M = {}

-- Check if a file or directory exists
M.exists = function(file)
  local stat = vim.loop.fs_stat(file)
  return stat ~= nil
end

-- Get OS name
M.get_os = function()
  return vim.loop.os_uname().sysname
end

-- Toggle boolean option
M.toggle_option = function(option)
  local value = not vim.api.nvim_get_option_value(option, {})
  vim.api.nvim_set_option_value(option, value, {})
  vim.notify(option .. " " .. tostring(value), vim.log.levels.INFO)
end

-- Reload configuration
M.reload_config = function()
  for name, _ in pairs(package.loaded) do
    if name:match('^core') or name:match('^plugins') then
      package.loaded[name] = nil
    end
  end
  
  dofile(vim.env.MYVIMRC)
  vim.notify("Configuration reloaded!", vim.log.levels.INFO)
end

return M 