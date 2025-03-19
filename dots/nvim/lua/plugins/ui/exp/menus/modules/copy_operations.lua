-- Copy Operations Module for NvimTree
-- Contains all clipboard-related functionality

local M = {}

-- Copy the node name without extension
function M.copy_name_only(node)
  local name = vim.fn.fnamemodify(node.name, ":r")
  vim.fn.setreg("+", name)
  vim.notify("Copied name to clipboard: " .. name, vim.log.levels.INFO)
end

-- Copy just the file extension
function M.copy_extension_only(node)
  local ext = vim.fn.fnamemodify(node.name, ":e")
  if ext and ext ~= "" then
    vim.fn.setreg("+", ext)
    vim.notify("Copied extension to clipboard: " .. ext, vim.log.levels.INFO)
  else
    vim.notify("No extension found", vim.log.levels.WARN)
  end
end

-- Copy the relative path from the current working directory
function M.copy_relative_path(node)
  local cwd = vim.fn.getcwd()
  local relative_path = node.absolute_path:gsub("^" .. vim.pesc(cwd) .. "/", "")
  vim.fn.setreg("+", relative_path)
  vim.notify("Copied relative path to clipboard: " .. relative_path, vim.log.levels.INFO)
end

-- Copy the absolute path
function M.copy_absolute_path(node)
  vim.fn.setreg("+", node.absolute_path)
  vim.notify("Copied absolute path to clipboard: " .. node.absolute_path, vim.log.levels.INFO)
end

-- Copy the directory path containing the node
function M.copy_directory_path(node)
  local dir = vim.fn.fnamemodify(node.absolute_path, ":h")
  vim.fn.setreg("+", dir)
  vim.notify("Copied directory path to clipboard: " .. dir, vim.log.levels.INFO)
end

-- Create a submenu with all copy operations
function M.create_copy_submenu(node, is_folder)
  -- Skip for folders if needed
  if is_folder then return nil end
  
  local copy_items = {}
  
  -- Add all copy operations
  table.insert(copy_items, { "Copy Name Only", function() M.copy_name_only(node) end })
  table.insert(copy_items, { "Copy Extension Only", function() M.copy_extension_only(node) end })
  table.insert(copy_items, { "Copy Relative Path", function() M.copy_relative_path(node) end })
  table.insert(copy_items, { "Copy Absolute Path", function() M.copy_absolute_path(node) end })
  table.insert(copy_items, { "Copy Directory Path", function() M.copy_directory_path(node) end })
  
  -- Format and return the menu
  return {
    title = "Copy Operations",
    icon = "📋",
    items = copy_items,
    item_icon = "󰆏 ",
    prompt = "Copy Operations > ",
    window_title = "📋 Copy: " .. (node.name or "")
  }
end

return M
