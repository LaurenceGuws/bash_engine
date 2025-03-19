-- Basic context menu functionality for NvimTree
-- Functions for common operations like open, edit, delete, etc.

local M = {}

-- Import the copy operations module for the Copy Path functionality
local copy_operations = require("plugins.ui.exp.menus.modules.copy_operations")

-- Main function to create the basic context menu
function M.create_basic_menu(node, is_folder, is_symlink, is_git_repo, api, fzf_lua)
  local menu_items = {}
  
  -- Common options
  table.insert(menu_items, { "Open", function() api.node.open.edit() end })
  table.insert(menu_items, { "Split Vertically", function() api.node.open.vertical() end })
  table.insert(menu_items, { "Split Horizontally", function() api.node.open.horizontal() end })
  table.insert(menu_items, { "Open in New Tab", function() api.node.open.tab() end })
  
  -- Folder specific options
  if is_folder then
    table.insert(menu_items, { "Expand", function() api.node.open.edit() end })
    table.insert(menu_items, { "Collapse", function() api.node.navigate.parent_close() end })
    table.insert(menu_items, { "Expand All Children", function() 
      api.node.open.edit()
      api.tree.expand_all()
    end })
    table.insert(menu_items, { "Collapse All Children", function() api.tree.collapse_all() end })
    table.insert(menu_items, { "Create File", function() api.fs.create() end })
    table.insert(menu_items, { "Create Directory", function()
      vim.ui.input({ prompt = "Create directory: " }, function(name)
        if name and name ~= "" then 
          api.fs.create({ prompt = false, is_dir = true, name = name }) 
        end
      end)
    end })
  end
  
  -- Git specific options
  if is_git_repo then
    table.insert(menu_items, { "Git Status", function()
      -- Save current directory
      local cwd = vim.fn.getcwd()
      -- Change to repo directory
      vim.cmd("cd " .. node.absolute_path)
      -- Run git status with FZF
      fzf_lua.git_status()
      -- Restore directory
      vim.defer_fn(function() vim.cmd("cd " .. cwd) end, 100)
    end })
    
    table.insert(menu_items, { "Git Branches", function()
      local cwd = vim.fn.getcwd()
      vim.cmd("cd " .. node.absolute_path)
      fzf_lua.git_branches()
      vim.defer_fn(function() vim.cmd("cd " .. cwd) end, 100)
    end })
    
    table.insert(menu_items, { "Git Commits", function()
      local cwd = vim.fn.getcwd()
      vim.cmd("cd " .. node.absolute_path)
      fzf_lua.git_commits()
      vim.defer_fn(function() vim.cmd("cd " .. cwd) end, 100)
    end })
  end
  
  -- File specific options
  if not is_folder then
    -- Use copy_operations module for path copying
    table.insert(menu_items, { "Copy Path", function()
      copy_operations.copy_absolute_path(node)
    end })
    
    -- Preview based on file type
    table.insert(menu_items, { "Preview", function()
      local path = node.absolute_path
      local extension = string.match(path, "%.([^%.]+)$")
      
      -- Choose preview method based on extension
      if extension and vim.tbl_contains({"md", "markdown"}, extension:lower()) then
        -- Use built-in markdown preview if available
        if pcall(require, "markdown-preview") then
          vim.cmd("MarkdownPreview")
        else
          -- Fallback to system preview
          vim.fn.jobstart({"xdg-open", path}, {detach = true})
        end
      elseif extension and vim.tbl_contains({"jpg", "jpeg", "png", "gif", "svg"}, extension:lower()) then
        -- Preview images
        vim.fn.jobstart({"xdg-open", path}, {detach = true})
      else
        -- Default to opening in editor
        api.node.open.edit()
      end
    end })
  end
  
  -- Common operations for both files and folders
  table.insert(menu_items, { "Rename", function() api.fs.rename() end })
  table.insert(menu_items, { "Delete", function() api.fs.remove() end })
  table.insert(menu_items, { "Cut", function() api.fs.cut() end })
  table.insert(menu_items, { "Copy", function() api.fs.copy.node() end })
  
  -- Paste option (always show since we can't check clipboard content)
  local can_paste = true
  if can_paste then
    table.insert(menu_items, { "Paste Here", function() api.fs.paste() end })
  end
  
  -- Advanced search options
  table.insert(menu_items, { "Find in Directory", function()
    local target = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
    fzf_lua.live_grep({ cwd = target })
  end })
  
  table.insert(menu_items, { "Find Files", function()
    local target = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
    fzf_lua.files({ cwd = target })
  end })

  return menu_items
end

return M 