local M = {}

-- Debug mode to help diagnose issues with theme switching
local DEBUG = true

-- Import the theme library
local theme_library = require("core.theme_library")

-- Function to show debug messages if debug mode is enabled
local function debug_print(msg)
  if DEBUG then
    vim.notify("[Theme Debug] " .. msg, vim.log.levels.INFO)
  end
end

-- Map to keep track of configured themes and their packages
M.themes = {
  -- This now serves as a cache of the most commonly used themes
  -- for full theme list, consult theme_library
  ["tokyonight"] = {
    package = "folke/tokyonight.nvim",
    variants = { "storm", "moon", "night", "day" },
  },
  ["nightfox"] = { 
    package = "EdenEast/nightfox.nvim",
    variants = { "nightfox", "dayfox", "dawnfox", "duskfox", "nordfox", "terafox", "carbonfox" },
  },
  ["catppuccin"] = {
    package = "catppuccin/nvim",
    variants = { "mocha", "macchiato", "frappe", "latte" },
  },
  ["default"] = {
    package = "vim",
    variants = {},
  }
}

-- Get available themes from the theme library
function M.get_available_themes()
  return theme_library.get_all_themes()
end

-- Apply necessary post-theme changes
function M.apply_post_theme_changes()
  -- Trigger color scheme event for plugins to update
  vim.cmd("doautocmd ColorScheme")
  
  -- Force redraw of UI components that might not have updated
  vim.schedule(function()
    -- Refresh certain plugins known to have issues with theme switching
    debug_print("Running plugin-specific refreshes")
    
    -- LSP UI elements
    pcall(vim.cmd, "doautocmd User LspUIRefresh")
    
    -- Tree-sitter highlighting
    pcall(vim.cmd, "TSRefresh")
    
    -- Status line refresh
    if pcall(require, "lualine") then
      debug_print("Refreshing lualine")
      require("lualine").refresh()
    end
    
    -- NvimTree refresh if it exists
    if pcall(require, "nvim-tree.api") then
      debug_print("Refreshing nvim-tree")
      require("nvim-tree.api").tree.reload()
    end
    
    -- Final redraw to ensure everything is updated
    vim.cmd("redraw!")
  end)
end

-- Set theme and apply it
function M.set_theme(theme_choice)
  if not theme_choice then 
    debug_print("No theme choice provided")
    return false 
  end
  
  debug_print("Setting theme: " .. theme_choice)
  
  -- Determine if we're switching between light and dark themes
  local current_bg = vim.opt.background:get()
  local is_light_theme = theme_choice:match("light") or theme_choice:match("day") or 
                         theme_choice:match("dawn") or theme_choice:match("latte")
  
  -- Force background setting based on theme name heuristics
  if is_light_theme then
    debug_print("Detected light theme, setting background=light")
    vim.opt.background = "light"
  else
    debug_print("Setting background=dark")
    vim.opt.background = "dark"
  end
  
  -- Clean up existing highlights before applying new theme
  debug_print("Clearing existing highlights")
  vim.cmd([[
    highlight clear
    syntax reset
  ]])
  
  -- Apply the theme using the theme library
  local ok, err = pcall(function()
    return theme_library.apply_theme(theme_choice)
  end)
  
  if not ok or err == false then
    vim.notify("Failed to apply theme: " .. theme_choice, vim.log.levels.ERROR)
    return false
  end
  
  -- Apply post-theme changes and UI refreshes
  M.apply_post_theme_changes()
  
  -- Store the selected theme in a global variable
  vim.g.selected_theme = theme_choice
  debug_print("Theme applied and saved as: " .. theme_choice)
  
  return true
end

-- Store current theme information for potential restoration
function M.get_current_theme()
  debug_print("Getting current theme")
  
  -- Try to get the current theme from our global variable
  if vim.g.selected_theme then
    debug_print("Found selected_theme global: " .. vim.g.selected_theme)
    return vim.g.selected_theme
  end
  
  -- Fallback to vim.g.colors_name which stores the active colorscheme
  if vim.g.colors_name then
    debug_print("Found colors_name: " .. vim.g.colors_name)
    
    -- Try to map the colorscheme name back to a theme choice
    local colorscheme = vim.g.colors_name
    local all_themes = M.get_available_themes()
    
    -- Check for exact match or base16 theme
    for _, theme in ipairs(all_themes) do
      local base, variant = theme:match("([^:]+):?(.*)")
      
      if colorscheme == base then
        debug_print("Matched colorscheme to theme: " .. theme)
        return theme
      end
      
      -- Special handling for base16
      if colorscheme:match("^base16") and base == "base16" then
        local base16_theme = colorscheme:match("^base16%-(.*)")
        if base16_theme == variant then
          debug_print("Matched base16 colorscheme to theme: " .. theme)
          return theme
        end
      end
    end
    
    -- Just return the colorscheme name if we can't match it
    return vim.g.colors_name
  end
  
  debug_print("No theme found, using default")
  -- Ultimate fallback
  return "default"
end

-- Enhanced version of the theme picker with a manual preview implementation
function M.pick_theme_enhanced()
  local themes = M.get_available_themes()
  local original_theme = M.get_current_theme()
  local current_idx = 1
  
  -- Find the index of the current theme in the list
  for i, theme in ipairs(themes) do
    if theme == original_theme then
      current_idx = i
      break
    end
  end
  
  debug_print("Starting enhanced picker with current theme at index: " .. current_idx)
  
  -- Create a custom buffer for theme selection
  local buf = vim.api.nvim_create_buf(false, true)
  local width = 50  -- Make wider to accommodate long theme names
  local height = math.min(#themes + 2, 20)  -- Allow more themes to be visible
  
  -- Set up UI position - centered in the screen
  local ui = vim.api.nvim_list_uis()[1]
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((ui.width - width) / 2),
    row = math.floor((ui.height - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Theme Picker (Total: " .. #themes .. " themes) ",
    title_pos = "center",
  }
  
  -- Create window
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  
  -- Update UI function to show themes list and highlight current selection
  local function update_ui(buf, win, themes, selected_idx, original_theme, page_offset)
    if not page_offset then page_offset = 0 end
    
    local lines = {}
    local height = vim.api.nvim_win_get_height(win) - 2  -- Adjust for header
    
    table.insert(lines, " Use ↑↓ to navigate, Enter to select, Esc to cancel, PgUp/PgDn to page ")
    table.insert(lines, " ")
    
    -- Determine visible range based on current page
    local start_idx = page_offset * height + 1
    local end_idx = math.min(start_idx + height - 1, #themes)
    
    -- Add pagination info
    local page_info = string.format(" Page %d/%d (%d-%d of %d) ", 
      math.floor(selected_idx / height) + 1, 
      math.ceil(#themes / height),
      start_idx, end_idx, #themes)
    
    for i = start_idx, end_idx do
      local theme = themes[i]
      local prefix = i == selected_idx and "→ " or "  "
      local suffix = theme == original_theme and " ✓" or ""
      table.insert(lines, prefix .. theme .. suffix)
    end
    
    -- Safely set lines in the buffer
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_set_option(buf, "modifiable", true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(buf, "modifiable", false)
      
      -- Only set cursor if window is still valid
      if vim.api.nvim_win_is_valid(win) then
        local cursor_line = (selected_idx - start_idx) + 3  -- +3 for header lines
        pcall(vim.api.nvim_win_set_cursor, win, {cursor_line, 2})
      end
    end
    
    -- Apply the currently selected theme for preview
    debug_print("Preview theme: " .. themes[selected_idx])
    pcall(M.set_theme, themes[selected_idx])
  end
  
  -- Calculate pagination
  local function update_view(selected_idx)
    local page_size = vim.api.nvim_win_get_height(win) - 2
    local page = math.floor((selected_idx - 1) / page_size)
    update_ui(buf, win, themes, selected_idx, original_theme, page)
  end
  
  -- Initialize
  update_ui(buf, win, themes, current_idx, original_theme)
  
  -- Set up keymaps
  local function setup_keymaps()
    local opts = { noremap = true, silent = true, buffer = buf }
    vim.keymap.set("n", "<ESC>", function()
      vim.api.nvim_win_close(win, true)
      debug_print("Restoring original theme: " .. original_theme)
      M.set_theme(original_theme)
      vim.notify("Theme selection canceled", vim.log.levels.INFO)
    end, opts)
    
    vim.keymap.set("n", "<CR>", function()
      local selected_theme = themes[current_idx]
      vim.api.nvim_win_close(win, true)
      debug_print("Selected theme: " .. selected_theme)
      M.set_theme(selected_theme)
      vim.notify("Theme changed to " .. selected_theme, vim.log.levels.INFO)
    end, opts)
    
    vim.keymap.set("n", "j", function()
      if current_idx < #themes then
        current_idx = current_idx + 1
        update_view(current_idx)
      end
    end, opts)
    
    vim.keymap.set("n", "k", function()
      if current_idx > 1 then
        current_idx = current_idx - 1
        update_view(current_idx)
      end
    end, opts)
    
    vim.keymap.set("n", "<Down>", function()
      if current_idx < #themes then
        current_idx = current_idx + 1
        update_view(current_idx)
      end
    end, opts)
    
    vim.keymap.set("n", "<Up>", function()
      if current_idx > 1 then
        current_idx = current_idx - 1
        update_view(current_idx)
      end
    end, opts)
    
    -- Add page up/down navigation
    vim.keymap.set("n", "<PageDown>", function()
      local page_size = vim.api.nvim_win_get_height(win) - 2
      current_idx = math.min(current_idx + page_size, #themes)
      update_view(current_idx)
    end, opts)
    
    vim.keymap.set("n", "<PageUp>", function()
      local page_size = vim.api.nvim_win_get_height(win) - 2
      current_idx = math.max(current_idx - page_size, 1)
      update_view(current_idx)
    end, opts)
    
    -- Add category filtering hotkeys
    vim.keymap.set("n", "b", function() -- base16 themes
      for i, theme in ipairs(themes) do
        if theme:match("^base16:") then
          current_idx = i
          update_view(current_idx)
          break
        end
      end
    end, opts)
    
    vim.keymap.set("n", "c", function() -- catppuccin themes
      for i, theme in ipairs(themes) do
        if theme:match("^catppuccin") then
          current_idx = i
          update_view(current_idx)
          break
        end
      end
    end, opts)
    
    vim.keymap.set("n", "g", function() -- gruvbox themes
      for i, theme in ipairs(themes) do
        if theme:match("^gruvbox") then
          current_idx = i
          update_view(current_idx)
          break
        end
      end
    end, opts)
    
    vim.keymap.set("n", "t", function() -- tokyonight themes
      for i, theme in ipairs(themes) do
        if theme:match("^tokyonight") then
          current_idx = i
          update_view(current_idx)
          break
        end
      end
    end, opts)
  end
  
  setup_keymaps()
  
  -- Set buffer to non-modifiable after setup
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- Create a user command to invoke the theme picker
vim.api.nvim_create_user_command("ThemePicker", function()
  M.pick_theme_enhanced()
end, {})

-- Create a simple version without preview for troubleshooting
vim.api.nvim_create_user_command("ThemePickerSimple", function()
  local themes = M.get_available_themes()
  local current_theme = M.get_current_theme()
  
  debug_print("Opening theme picker with current theme: " .. current_theme)
  
  vim.ui.select(themes, { 
    prompt = "Select Theme (Total: " .. #themes .. " themes):",
    format_item = function(item)
      -- If current theme, add indicator
      if current_theme == item then
        return item .. " ✓"
      end
      return item
    end
  }, function(choice)
    if choice then
      -- Apply the selected theme
      debug_print("User selected: " .. choice)
      if M.set_theme(choice) then
        vim.notify("Theme changed to " .. choice, vim.log.levels.INFO)
      end
    else
      debug_print("Theme selection canceled")
      vim.notify("Theme selection canceled", vim.log.levels.INFO)
    end
  end)
end, {})

-- Create a user command to toggle debugging
vim.api.nvim_create_user_command("ThemeDebug", function()
  DEBUG = not DEBUG
  vim.notify("Theme debug mode: " .. (DEBUG and "ON" or "OFF"), vim.log.levels.INFO)
end, {})

-- Command to directly set a theme
vim.api.nvim_create_user_command("SetTheme", function(opts)
  if M.set_theme(opts.args) then
    vim.notify("Theme changed to " .. opts.args, vim.log.levels.INFO)
  end
end, { nargs = 1, complete = function()
  return M.get_available_themes()
end })

return M 