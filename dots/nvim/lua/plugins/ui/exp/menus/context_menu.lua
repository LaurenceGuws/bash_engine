-- Context Menu Manager for NvimTree
-- Main entry point for context menu functionality

local M = {}

-- Imports
local basic_menu = require("plugins.ui.exp.menus.basic_menu")
local advanced_menu = require("plugins.ui.exp.menus.advanced_menu")
local menu_display = require("plugins.ui.exp.menus.menu_display")

-- Opens the context menu
function M.open_context_menu()
  -- Make sure FZF-lua is available
  local fzf_status_ok, fzf_lua = pcall(require, "fzf-lua")
  if not fzf_status_ok then
    vim.notify("fzf-lua not found, context menu is not available", vim.log.levels.WARN)
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
  
  -- Create main menu items
  local menu_items = basic_menu.create_basic_menu(
    node, is_folder, is_symlink, is_git_repo, api, fzf_lua
  )
  
  -- Create Advanced Menu option
  local adv_categories = advanced_menu.create_advanced_menu(
    node, is_folder, is_symlink, is_git_repo, api, fzf_lua
  )
  
  -- Only add advanced menu if we have categories
  if #adv_categories > 0 then
    table.insert(menu_items, { "Advanced", function()
      -- Format categories for display
      local category_texts, category_actions = menu_display.format_advanced_categories(adv_categories)
      
      -- Show advanced menu
      fzf_lua.fzf_exec(category_texts, {
        prompt = "Advanced > ",
        actions = {
          ["default"] = function(selected)
            if selected and selected[1] then
              local action = category_actions[selected[1]]
              if action then action() end
            end
          end,
        },
        winopts = {
          relative = "cursor",
          row = 1,
          col = 1,
          width = 40,
          height = math.min(#adv_categories + 2, 20),
          border = "rounded",
          title = "⚙️  Advanced: " .. (node.name or ""),
          hl = {
            border = "FloatBorder",
            normal = "Normal",
            cursor = "Cursor",
            cursorline = "CursorLine",
            title = "FloatTitle",
          },
          preview = {
            hidden = "hidden",
          },
          inert = true,
        },
        fzf_opts = {
          ["--layout"] = "reverse",
          ["--info"] = "inline",
          ["--pointer"] = "→",
          ["--marker"] = "•",
          ["--ansi"] = "",
          ["--color"] = "bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#cba6f7,info:#cdd6f4,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8",
        },
      })
    end })
  end
  
  -- Format menu items with icons
  local menu_texts, menu_actions = menu_display.format_items_with_icons(menu_items)
  
  -- Display the menu
  menu_display.show_fzf_menu(menu_texts, menu_actions, node.name, fzf_lua)
end

return M 