-- Context Menu Manager for NvimTree
-- Main entry point for context menu functionality

local M = {}

-- Import modules directly
local basic_menu = require("plugins.ui.exp.menus.basic_menu")
local copy_operations = require("plugins.ui.exp.menus.modules.copy_operations")
local file_operations = require("plugins.ui.exp.menus.modules.file_operations")
local git_operations = require("plugins.ui.exp.menus.modules.git_operations")
local search_operations = require("plugins.ui.exp.menus.modules.search_operations")
local archive_operations = require("plugins.ui.exp.menus.modules.archive_operations")
local bookmark_operations = require("plugins.ui.exp.menus.modules.bookmark_operations")
local filesystem_operations = require("plugins.ui.exp.menus.modules.filesystem_operations")
local external_app_operations = require("plugins.ui.exp.menus.modules.external_app_operations")
local project_operations = require("plugins.ui.exp.menus.modules.project_operations")
local filter_operations = require("plugins.ui.exp.menus.modules.filter_operations")

-- Format menu items with icons and keyboard shortcuts
local function format_items_with_icons(menu_items)
  -- Transform menu items to include icons and keybindings
  local formatted_items = {}
  local max_text_length = 0
  
  -- Associate actions with common nvim-tree keybindings
  local keybinding_map = {
    ["Open"] = "<CR>",
    ["Open: Vertical Split"] = "<C-v>",
    ["Open: Horizontal Split"] = "<C-x>",
    ["Open: Tab"] = "<C-t>",
    ["Close Directory"] = "h",
    ["Expand"] = "l",
    ["Expand All"] = "E",
    ["Collapse"] = "W",
    ["Create"] = "a",
    ["Rename"] = "r",
    ["Delete"] = "d",
    ["Cut"] = "x",
    ["Copy"] = "c",
    ["Paste"] = "p",
    ["Refresh"] = "R",
    ["Search"] = "S",
    ["Copy Name"] = "y",
    ["Copy Relative Path"] = "Y",
    ["Copy Absolute Path"] = "gy",
    ["System Open"] = "s",
    ["Help"] = "g?",
    ["Context Menu"] = "m",
    ["Filter"] = "f",
  }
  
  -- First pass to find the longest text for alignment
  for _, item in ipairs(menu_items) do
    local title = item[1]
    max_text_length = math.max(max_text_length, #title)
  end
  
  -- Now format the items with padding
  for _, item in ipairs(menu_items) do
    local title = item[1]
    local icon = " "
    local keybind = keybinding_map[title] or ""
    
    -- Add icons based on action
    if string.match(title, "Open") then 
      icon = "󰈔 "
    elseif string.match(title, "Split") then 
      icon = "󰯌 "
    elseif string.match(title, "Tab") then 
      icon = "󰓩 "
    elseif string.match(title, "Expand") then 
      icon = "󰁔 "
    elseif string.match(title, "Collapse") then 
      icon = "󰁍 "
    elseif string.match(title, "Create") then 
      icon = "󰙴 "
    elseif string.match(title, "Rename") then 
      icon = "󰑕 "
    elseif string.match(title, "Delete") then 
      icon = "󰚃 "
    elseif string.match(title, "Cut") then 
      icon = "󰆐 "
    elseif string.match(title, "Copy") then 
      icon = "󰆏 "
    elseif string.match(title, "Paste") then 
      icon = "󰆒 "
    elseif string.match(title, "Preview") then 
      icon = "󰱼 "
    elseif string.match(title, "Git") then 
      icon = "󰊢 "
    elseif string.match(title, "Find") then 
      icon = "󰍉 "
    elseif string.match(title, "Search") then 
      icon = "🔍 "
    elseif string.match(title, "Advanced") then 
      icon = "⚙️ "
    elseif string.match(title, "Archive") then
      icon = "📦 "
    elseif string.match(title, "Bookmark") then
      icon = "🔖 "
    elseif string.match(title, "Help") then
      icon = "❓ "
    elseif string.match(title, "External") then
      icon = "🔗 "
    elseif string.match(title, "Filesystem") then
      icon = "🖴 "
    elseif string.match(title, "Project") then
      icon = "📋 "
    elseif string.match(title, "Filter") then
      icon = "🔍 "
    end
    
    -- Add padding to align keybindings
    local padding = string.rep(" ", max_text_length - #title + 2)
    local display_text = icon .. " " .. title
    
    -- Only add keybinding if it exists
    if keybind ~= "" then
      display_text = display_text .. padding .. keybind
    end
    
    table.insert(formatted_items, {
      text = display_text,
      action = item[2]
    })
  end
  
  return formatted_items
end

-- Create a simple NUI Menu - keyboard focused
local function create_nui_menu(items, options)
  local Menu = require("nui.menu")
  local NuiLine = require("nui.line")
  local NuiText = require("nui.text")
  
  -- Process menu items
  local menu_items = {}
  
  for _, item in ipairs(items) do
    table.insert(menu_items, Menu.item(
      NuiLine({ NuiText(item.text) }),
      { on_submit = item.action }
    ))
  end
  
  -- Set defaults for menu options
  options = vim.tbl_deep_extend("force", {
    position = "50%",
    relative = "editor",
    border = {
      style = "rounded",
      text = {
        top = options.title or " Menu ",
        top_align = "center",
        bottom = " ↓↑:Navigate │ Enter:Select │ Esc:Cancel ",
        bottom_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      cursorline = true,
    },
    size = {
      width = "38%",
      height = math.min(#items + 2, 20), -- Adjust height based on content
    },
  }, options or {})
  
  -- Create the menu with keyboard navigation focus
  local menu = Menu(options, {
    lines = menu_items,
    max_width = 60,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>" },
      submit = { "<CR>", "<Space>" },
    },
    on_submit = function(item)
      if item.on_submit then
        item.on_submit()
      end
    end,
    on_close = function() end,
  })
  
  return menu
end

-- Show a popup menu
local function show_popup_menu(menu_items, title)
  local menu = create_nui_menu(menu_items, {
    title = " " .. title .. " ",
    position = {
      row = 1,
      col = 0,
    },
    relative = "cursor",
    size = {
      width = 45,
      height = math.min(#menu_items + 2, 20),
    },
  })
  
  -- Mount the menu
  menu:mount()
end

-- Show a submenu
local function show_submenu(submenu)
  local menu_items = {}
  
  for i, item in ipairs(submenu.items) do
    local title = item[1]
    local icon = ""
    
    if type(submenu.item_icon) == "function" then
      icon = submenu.item_icon(title)
    else
      icon = submenu.item_icon or " "
    end
    
    table.insert(menu_items, {
      text = icon .. " " .. title,
      action = item[2]
    })
  end
  
  show_popup_menu(menu_items, submenu.title)
end

-- Display a help menu with common nvim-tree keybindings
local function show_help_menu()
  local help_items = {
    { text = "Common nvim-tree Keybindings:", action = function() end },
    { text = "─────────────────────────────", action = function() end },
    { text = "<CR>, o       Open file or directory", action = function() end },
    { text = "h            Close directory", action = function() end },
    { text = "v, <C-v>     Open in vertical split", action = function() end },
    { text = "<C-x>        Open in horizontal split", action = function() end },
    { text = "<C-t>        Open in new tab", action = function() end },
    { text = "a            Create file/directory", action = function() end },
    { text = "d            Delete", action = function() end },
    { text = "r            Rename", action = function() end },
    { text = "x            Cut", action = function() end },
    { text = "c            Copy", action = function() end },
    { text = "p            Paste", action = function() end },
    { text = "y            Copy name", action = function() end },
    { text = "Y            Copy relative path", action = function() end },
    { text = "gy           Copy absolute path", action = function() end },
    { text = "m            Context menu", action = function() end },
    { text = "f            Filter operations", action = function() end },
    { text = "R            Refresh", action = function() end },
    { text = "?            Show help", action = function() end },
  }
  
  -- Create a NUI Menu for help
  local Menu = require("nui.menu")
  local NuiLine = require("nui.line")
  local NuiText = require("nui.text")
  
  local menu_items = {}
  for _, item in ipairs(help_items) do
    table.insert(menu_items, Menu.item(
      NuiLine({ NuiText(item.text) }),
      { on_submit = item.action }
    ))
  end
  
  local menu = Menu({
    position = "50%",
    size = {
      width = 40,
      height = #help_items + 2,
    },
    border = {
      style = "rounded",
      text = {
        top = " nvim-tree Help ",
        top_align = "center",
        bottom = " Press Esc to close ",
        bottom_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      cursorline = false,
    },
  }, {
    lines = menu_items,
    keymap = {
      close = { "<Esc>", "<CR>", "q", "<Space>", "<C-c>" },
    },
  })
  
  menu:mount()
end

-- Opens the context menu
function M.open_context_menu()
  -- Try to get NuiMenu if available
  local has_nui_menu = pcall(require, "nui.menu")
  if not has_nui_menu then
    vim.notify("nui.nvim is required for the context menu", vim.log.levels.ERROR)
    return
  end
  
  -- Get nvim-tree API
  local api = require("nvim-tree.api")
  
  -- Get current node
  local node = api.tree.get_node_under_cursor()
  if not node then return end
  
  -- Determine node types
  local is_folder = node.fs_stat and node.fs_stat.type == "directory" or false
  local is_symlink = node.fs_stat and node.fs_stat.is_symlink or false
  local is_git_repo = false
  
  -- Check if it's a git repo (if in a directory with .git)
  if is_folder then
    local git_dir = node.absolute_path .. "/.git"
    local stat = vim.loop.fs_stat(git_dir)
    is_git_repo = stat and (stat.type == "directory") or false
  end
  
  -- Get FZF-lua if available
  local fzf_status_ok, fzf_lua = pcall(require, "fzf-lua")
  if not fzf_status_ok then
    fzf_lua = nil
  end
  
  -- Create main menu items
  local menu_items = basic_menu.create_basic_menu(
    node, is_folder, is_symlink, is_git_repo, api, fzf_lua
  )
  
  -- Add filter operations to main menu
  table.insert(menu_items, { "Filter", function()
    -- Show filter submenu directly
    local filter_submenu = filter_operations.create_filter_submenu(node)
    if filter_submenu then
      show_submenu(filter_submenu)
    end
  end })
  
  -- Create Advanced Menu categories
  local advanced_categories = {}
  
  -- Add copy operations submenu (for files only)
  local copy_submenu = copy_operations.create_copy_submenu(node, is_folder)
  if copy_submenu then 
    table.insert(advanced_categories, copy_submenu)
  end
  
  -- Add git operations submenu (for git repos only)
  local git_submenu = git_operations.create_git_submenu(node, is_folder, is_git_repo, fzf_lua)
  if git_submenu then
    table.insert(advanced_categories, git_submenu)
  end
  
  -- Add file operations submenu
  local file_submenu = file_operations.create_file_operations_menu(node, is_folder, api, fzf_lua)
  if file_submenu then
    table.insert(advanced_categories, file_submenu)
  end
  
  -- Add search operations submenu
  local search_submenu = search_operations.create_search_submenu(node, is_folder, fzf_lua)
  if search_submenu then
    table.insert(advanced_categories, search_submenu)
  end
  
  -- Add archive operations submenu
  local archive_submenu = archive_operations.create_archive_submenu(node, is_folder, api)
  if archive_submenu then
    table.insert(advanced_categories, archive_submenu)
  end
  
  -- Add bookmark operations submenu
  local bookmark_submenu = bookmark_operations.create_bookmark_submenu(node, api, fzf_lua)
  if bookmark_submenu then
    table.insert(advanced_categories, bookmark_submenu)
  end
  
  -- Add filesystem operations submenu
  local filesystem_submenu = filesystem_operations.create_filesystem_submenu(node, is_folder)
  if filesystem_submenu then
    table.insert(advanced_categories, filesystem_submenu)
  end
  
  -- Add external app operations submenu
  local external_app_submenu = external_app_operations.create_external_app_submenu(node, is_folder)
  if external_app_submenu then
    table.insert(advanced_categories, external_app_submenu)
  end
  
  -- Add project operations submenu
  local project_submenu = project_operations.create_project_submenu(node, is_folder)
  if project_submenu then
    table.insert(advanced_categories, project_submenu)
  end
  
  -- Add filter operations submenu to advanced categories
  local filter_submenu = filter_operations.create_filter_submenu(node)
  if filter_submenu then
    table.insert(advanced_categories, filter_submenu)
  end
  
  -- Only add advanced menu if we have categories
  if #advanced_categories > 0 then
    table.insert(menu_items, { "Advanced", function()
      -- Create a list of categories for the submenu
      local category_items = {}
      
      for _, category in ipairs(advanced_categories) do
        table.insert(category_items, {
          text = (category.icon or "") .. " " .. category.title,
          action = function()
            show_submenu(category)
          end
        })
      end
      
      show_popup_menu(category_items, "Advanced Options")
    end })
  end
  
  -- Add help menu entry
  table.insert(menu_items, { "Help", function()
    show_help_menu()
  end })
  
  -- Format and show menu
  local formatted_items = format_items_with_icons(menu_items)
  show_popup_menu(formatted_items, "Actions: " .. (node.name or ""))
end

-- Add this to plugins section to ensure nui.nvim is available
function M.get_dependencies()
  return {
    "MunifTanjim/nui.nvim" -- UI component library
  }
end

return M 