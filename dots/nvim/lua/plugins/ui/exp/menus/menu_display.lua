-- Menu display utilities
-- Functions to format and display menus

local M = {}

-- Format menu items with icons
function M.format_items_with_icons(menu_items)
  local menu_texts = {}
  local menu_actions = {}
  
  -- Format menu items with icons
  for i, item in ipairs(menu_items) do
    local title = item[1]
    local icon = " "
    
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
    elseif string.match(title, "Advanced") then 
      icon = "⚙️ "
    end
    
    local menu_text = string.format("%s %s", icon, title)
    table.insert(menu_texts, menu_text)
    menu_actions[menu_text] = item[2]
  end
  
  return menu_texts, menu_actions
end

-- Format advanced categories
function M.format_advanced_categories(advanced_categories)
  local category_texts = {}
  local category_actions = {}
  
  for _, category in ipairs(advanced_categories) do
    local title = category.title
    local icon = category.icon
    
    local menu_text = string.format("%s %s", icon, title)
    table.insert(category_texts, menu_text)
    
    -- Create action to show the submenu
    category_actions[menu_text] = function()
      M.show_submenu(category)
    end
  end
  
  return category_texts, category_actions
end

-- Show submenu
function M.show_submenu(category)
  local formatted_items, actions
  
  if type(category.item_icon) == "function" then
    -- Handle dynamic icons
    formatted_items = {}
    actions = {}
    
    for i, item in ipairs(category.items) do
      local title = item[1]
      local icon = category.item_icon(title)
      
      local menu_text = string.format("%s %s", icon, title)
      table.insert(formatted_items, menu_text)
      actions[menu_text] = item[2]
    end
  else
    -- Simple static icon
    formatted_items = {}
    actions = {}
    
    for i, item in ipairs(category.items) do
      local title = item[1]
      local icon = category.item_icon or " "
      
      local menu_text = string.format("%s %s", icon, title)
      table.insert(formatted_items, menu_text)
      actions[menu_text] = item[2]
    end
  end
  
  -- Show submenu with FZF
  require("fzf-lua").fzf_exec(formatted_items, {
    prompt = category.prompt,
    actions = {
      ["default"] = function(selected)
        if selected and selected[1] then
          local action = actions[selected[1]]
          if action then action() end
        end
      end,
    },
    winopts = {
      relative = "cursor",
      row = 1,
      col = 1,
      width = 40,
      height = math.min(#category.items + 2, 15),
      border = "rounded",
      title = category.window_title,
      inert = true,
    },
    fzf_opts = {
      ["--layout"] = "reverse",
      ["--info"] = "inline",
    },
  })
end

-- Show the main FZF context menu
function M.show_fzf_menu(menu_texts, menu_actions, node_name, fzf_lua)
  fzf_lua.fzf_exec(menu_texts, {
    prompt = "Actions > ",
    actions = {
      ["default"] = function(selected)
        if selected and selected[1] then
          local action = menu_actions[selected[1]]
          if action then action() end
        end
      end,
    },
    winopts = {
      relative = "cursor",
      row = 1,
      col = 1,
      width = 40,
      height = math.min(#menu_texts + 2, 20),
      border = "rounded",
      title = "󱘖  Actions: " .. (node_name or ""),
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
      -- Set inert mode to true so it doesn't steal focus
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
end

return M 