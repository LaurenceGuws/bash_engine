-- Filter Operations Module for NvimTree Context Menu
-- Provides fine-grained filtering of files and folders in the explorer

local M = {}

-- Store the current active filters
M.active_filters = {
  extensions = {},
  patterns = {},
  custom_filter = nil,
  show_dotfiles = true,
  show_gitignored = false,
  size = {
    min = nil,
    max = nil
  },
  time = {
    older_than = nil,
    newer_than = nil
  }
}

-- Store filter presets for quick application
M.filter_presets = {}

-- Icons for visual representation
local icons = {
  active = "✅",
  inactive = "❌",
  added = "➕",
  removed = "➖",
  filter = "🔍",
  pattern = "🔣",
  extension = "📄",
  preset = "📁",
  save = "💾",
  dotfiles = "📋",
  gitignored = "📜",
  reset = "🔄",
  toggle_on = "🟢",
  toggle_off = "🔴",
}

-- Color definitions for consistent styling
local colors = {
  title = "%#NvimTreeSpecialFile#",
  active = "%#String#",
  inactive = "%#Comment#",
  added = "%#DiffAdd#",
  removed = "%#DiffDelete#", 
  info = "%#DiagnosticInfo#",
  warn = "%#DiagnosticWarn#",
  reset = "%#ErrorMsg#",
  normal = "%#Normal#",
  highlight = "%#WildMenu#",
  feature = "%#Function#",
}

-- Load filter presets from file
local function load_presets()
  local preset_file = vim.fn.stdpath("data") .. "/nvim_tree_filter_presets.json"
  local file = io.open(preset_file, "r")
  if file then
    local content = file:read("*all")
    file:close()
    
    local status, presets = pcall(vim.fn.json_decode, content)
    if status then
      M.filter_presets = presets
      vim.notify(colors.info .. "Filter presets loaded: " .. colors.highlight .. 
                table.concat(vim.tbl_keys(presets), ", ") .. colors.normal, 
                vim.log.levels.INFO)
    else
      vim.notify(colors.warn .. "Failed to parse filter presets: " .. presets .. colors.normal, 
                vim.log.levels.WARN)
    end
  end
end

-- Save filter presets to file
local function save_presets()
  local preset_file = vim.fn.stdpath("data") .. "/nvim_tree_filter_presets.json"
  local status, encoded = pcall(vim.fn.json_encode, M.filter_presets)
  
  if not status then
    vim.notify(colors.warn .. "Failed to encode filter presets: " .. encoded .. colors.normal, 
              vim.log.levels.ERROR)
    return
  end
  
  local file = io.open(preset_file, "w")
  if file then
    file:write(encoded)
    file:close()
    vim.notify(colors.active .. "Filter presets saved " .. icons.save .. colors.normal, 
              vim.log.levels.INFO)
  else
    vim.notify(colors.warn .. "Failed to save filter presets" .. colors.normal, 
              vim.log.levels.ERROR)
  end
end

-- Format a list of items with color
local function format_list(items, item_prefix, color)
  if #items == 0 then return color .. "None" .. colors.normal end
  
  local result = {}
  for _, item in ipairs(items) do
    table.insert(result, color .. item_prefix .. item .. colors.normal)
  end
  
  return table.concat(result, ", ")
end

-- Initialize the module
local function init()
  -- Load any saved presets
  load_presets()
  
  -- Set up autocmd to apply filters when nvim-tree refreshes
  vim.api.nvim_create_autocmd("User", {
    pattern = "NvimTreeRefresh",
    callback = function()
      M.apply_filters()
    end,
    desc = "Apply NvimTree filters on refresh"
  })
  
  -- Create highlight groups for filter UI
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      -- Create custom highlight groups for filter module
      vim.api.nvim_set_hl(0, "NvimTreeFilterTitle", { link = "Title", default = true })
      vim.api.nvim_set_hl(0, "NvimTreeFilterActive", { link = "String", default = true })
      vim.api.nvim_set_hl(0, "NvimTreeFilterInactive", { link = "Comment", default = true })
      vim.api.nvim_set_hl(0, "NvimTreeFilterAdded", { link = "DiffAdd", default = true })
      vim.api.nvim_set_hl(0, "NvimTreeFilterRemoved", { link = "DiffDelete", default = true })
    end,
  })
  
  -- Trigger the autocmd to set highlights right away
  vim.cmd("doautocmd ColorScheme")
end

-- Apply filters to nvim-tree
function M.apply_filters()
  local nvim_tree_config = require("nvim-tree.config")
  
  -- Get the current filters configuration
  local filters = nvim_tree_config.get_config().filters
  
  -- Apply extension filters
  if #M.active_filters.extensions > 0 then
    filters.exclude = M.active_filters.extensions
  else
    filters.exclude = {}
  end
  
  -- Apply dotfile filter
  filters.dotfiles = not M.active_filters.show_dotfiles
  
  -- Apply git ignored filter
  filters.git_ignored = not M.active_filters.show_gitignored
  
  -- Apply custom filter if set
  if M.active_filters.custom_filter then
    filters.custom = {M.active_filters.custom_filter}
  else
    filters.custom = {}
  end
  
  -- Add pattern filters to custom
  if #M.active_filters.patterns > 0 then
    for _, pattern in ipairs(M.active_filters.patterns) do
      table.insert(filters.custom, pattern)
    end
  end
  
  -- Set the updated filters
  nvim_tree_config.set_config({
    filters = filters
  })
  
  -- Refresh the tree to apply filters
  local api = require("nvim-tree.api")
  api.tree.reload()
end

-- Reset all filters
function M.reset_filters()
  M.active_filters = {
    extensions = {},
    patterns = {},
    custom_filter = nil,
    show_dotfiles = true,
    show_gitignored = false,
    size = {
      min = nil,
      max = nil
    },
    time = {
      older_than = nil,
      newer_than = nil
    }
  }
  
  M.apply_filters()
  vim.notify(colors.reset .. "All filters reset " .. icons.reset .. colors.normal, 
            vim.log.levels.INFO)
end

-- Toggle showing dotfiles
function M.toggle_dotfiles()
  M.active_filters.show_dotfiles = not M.active_filters.show_dotfiles
  M.apply_filters()
  
  local status_icon = M.active_filters.show_dotfiles and icons.toggle_on or icons.toggle_off
  local status_color = M.active_filters.show_dotfiles and colors.active or colors.inactive
  vim.notify(status_color .. "Dotfiles " .. 
            (M.active_filters.show_dotfiles and "shown" or "hidden") .. 
            " " .. status_icon .. colors.normal, vim.log.levels.INFO)
end

-- Toggle showing git ignored files
function M.toggle_gitignored()
  M.active_filters.show_gitignored = not M.active_filters.show_gitignored
  M.apply_filters()
  
  local status_icon = M.active_filters.show_gitignored and icons.toggle_on or icons.toggle_off
  local status_color = M.active_filters.show_gitignored and colors.active or colors.inactive
  vim.notify(status_color .. "Git ignored files " .. 
            (M.active_filters.show_gitignored and "shown" or "hidden") .. 
            " " .. status_icon .. colors.normal, vim.log.levels.INFO)
end

-- Add extension filter
function M.filter_by_extension()
  -- Create a floating window with a colorful prompt
  vim.ui.input({
    prompt = colors.title .. "Enter file extension to filter (without dot): " .. colors.normal,
  }, function(input)
    if not input or input == "" then return end
    
    -- Add extension to filters if not already present
    if not vim.tbl_contains(M.active_filters.extensions, input) then
      table.insert(M.active_filters.extensions, input)
      M.apply_filters()
      vim.notify(colors.added .. "Added filter for " .. colors.highlight .. 
                "." .. input .. colors.added .. " files " .. 
                icons.added .. colors.normal, vim.log.levels.INFO)
    else
      vim.notify(colors.warn .. "Filter for ." .. input .. " already exists" .. 
                colors.normal, vim.log.levels.WARN)
    end
  end)
end

-- Remove extension filter
function M.remove_extension_filter()
  if #M.active_filters.extensions == 0 then
    vim.notify(colors.warn .. "No extension filters to remove" .. colors.normal, 
              vim.log.levels.WARN)
    return
  end
  
  -- Prepare colorful extension display
  local formatted_extensions = {}
  for i, ext in ipairs(M.active_filters.extensions) do
    formatted_extensions[i] = colors.highlight .. "." .. ext .. colors.normal
  end
  
  vim.ui.select(M.active_filters.extensions, {
    prompt = colors.title .. "Select extension filter to remove:" .. colors.normal,
    format_item = function(item)
      return colors.highlight .. "." .. item .. colors.normal
    end,
  }, function(choice)
    if not choice then return end
    
    -- Remove the selected extension
    for i, ext in ipairs(M.active_filters.extensions) do
      if ext == choice then
        table.remove(M.active_filters.extensions, i)
        break
      end
    end
    
    M.apply_filters()
    vim.notify(colors.removed .. "Removed filter for " .. colors.highlight .. 
              "." .. choice .. colors.removed .. " files " .. 
              icons.removed .. colors.normal, vim.log.levels.INFO)
  end)
end

-- Add pattern filter
function M.filter_by_pattern()
  vim.ui.input({
    prompt = colors.title .. "Enter pattern to filter (Lua pattern): " .. colors.normal,
  }, function(input)
    if not input or input == "" then return end
    
    -- Add pattern to filters if not already present
    if not vim.tbl_contains(M.active_filters.patterns, input) then
      table.insert(M.active_filters.patterns, input)
      M.apply_filters()
      vim.notify(colors.added .. "Added filter for pattern: " .. colors.highlight .. 
                input .. " " .. icons.added .. colors.normal, vim.log.levels.INFO)
    else
      vim.notify(colors.warn .. "Filter for pattern already exists" .. colors.normal, 
                vim.log.levels.WARN)
    end
  end)
end

-- Remove pattern filter
function M.remove_pattern_filter()
  if #M.active_filters.patterns == 0 then
    vim.notify(colors.warn .. "No pattern filters to remove" .. colors.normal, 
              vim.log.levels.WARN)
    return
  end
  
  -- Prepare colorful pattern display
  local formatted_patterns = {}
  for i, pattern in ipairs(M.active_filters.patterns) do
    formatted_patterns[i] = colors.highlight .. pattern .. colors.normal
  end
  
  vim.ui.select(M.active_filters.patterns, {
    prompt = colors.title .. "Select pattern filter to remove:" .. colors.normal,
    format_item = function(item)
      return colors.highlight .. item .. colors.normal
    end,
  }, function(choice)
    if not choice then return end
    
    -- Remove the selected pattern
    for i, pattern in ipairs(M.active_filters.patterns) do
      if pattern == choice then
        table.remove(M.active_filters.patterns, i)
        break
      end
    end
    
    M.apply_filters()
    vim.notify(colors.removed .. "Removed filter for pattern: " .. colors.highlight .. 
              choice .. " " .. icons.removed .. colors.normal, vim.log.levels.INFO)
  end)
end

-- Save current filters as a preset
function M.save_filter_preset()
  vim.ui.input({
    prompt = colors.title .. "Enter name for filter preset: " .. colors.normal,
  }, function(input)
    if not input or input == "" then return end
    
    -- Add preset
    M.filter_presets[input] = vim.deepcopy(M.active_filters)
    save_presets()
    
    vim.notify(colors.active .. "Saved filter preset: " .. colors.highlight .. 
              input .. " " .. icons.save .. colors.normal, vim.log.levels.INFO)
  end)
end

-- Load a filter preset
function M.load_filter_preset()
  local preset_names = {}
  for name, _ in pairs(M.filter_presets) do
    table.insert(preset_names, name)
  end
  
  if #preset_names == 0 then
    vim.notify(colors.warn .. "No filter presets available" .. colors.normal, 
              vim.log.levels.WARN)
    return
  end
  
  vim.ui.select(preset_names, {
    prompt = colors.title .. "Select filter preset to load:" .. colors.normal,
    format_item = function(item)
      return colors.highlight .. item .. colors.normal
    end,
  }, function(choice)
    if not choice then return end
    
    -- Load the selected preset
    M.active_filters = vim.deepcopy(M.filter_presets[choice])
    M.apply_filters()
    
    vim.notify(colors.active .. "Loaded filter preset: " .. colors.highlight .. 
              choice .. " " .. icons.preset .. colors.normal, vim.log.levels.INFO)
  end)
end

-- Delete a filter preset
function M.delete_filter_preset()
  local preset_names = {}
  for name, _ in pairs(M.filter_presets) do
    table.insert(preset_names, name)
  end
  
  if #preset_names == 0 then
    vim.notify(colors.warn .. "No filter presets to delete" .. colors.normal, 
              vim.log.levels.WARN)
    return
  end
  
  vim.ui.select(preset_names, {
    prompt = colors.title .. "Select filter preset to delete:" .. colors.normal,
    format_item = function(item)
      return colors.highlight .. item .. colors.normal
    end,
  }, function(choice)
    if not choice then return end
    
    -- Remove the selected preset
    M.filter_presets[choice] = nil
    save_presets()
    
    vim.notify(colors.removed .. "Deleted filter preset: " .. colors.highlight .. 
              choice .. " " .. icons.removed .. colors.normal, vim.log.levels.INFO)
  end)
end

-- Show current active filters with colorful formatting
function M.show_active_filters()
  -- Create a stylish header
  local lines = {
    colors.title .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━" .. colors.normal,
    colors.title .. " 🔍 ACTIVE FILTERS " .. icons.filter .. colors.normal,
    colors.title .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━" .. colors.normal,
  }
  
  -- Add dotfiles status
  local dotfiles_status = M.active_filters.show_dotfiles and 
                        colors.active .. "SHOWN " .. icons.toggle_on .. colors.normal or 
                        colors.inactive .. "HIDDEN " .. icons.toggle_off .. colors.normal
  table.insert(lines, "📋 Dotfiles: " .. dotfiles_status)
  
  -- Add git ignored status
  local git_status = M.active_filters.show_gitignored and 
                    colors.active .. "SHOWN " .. icons.toggle_on .. colors.normal or 
                    colors.inactive .. "HIDDEN " .. icons.toggle_off .. colors.normal
  table.insert(lines, "📜 Git ignored files: " .. git_status)
  
  -- Add extension filters
  if #M.active_filters.extensions > 0 then
    table.insert(lines, "")
    table.insert(lines, colors.feature .. "📄 Filtered Extensions:" .. colors.normal)
    for _, ext in ipairs(M.active_filters.extensions) do
      table.insert(lines, "  " .. colors.highlight .. "." .. ext .. colors.normal)
    end
  end
  
  -- Add pattern filters
  if #M.active_filters.patterns > 0 then
    table.insert(lines, "")
    table.insert(lines, colors.feature .. "🔣 Filtered Patterns:" .. colors.normal)
    for _, pattern in ipairs(M.active_filters.patterns) do
      table.insert(lines, "  " .. colors.highlight .. pattern .. colors.normal)
    end
  end
  
  -- Add custom filter if set
  if M.active_filters.custom_filter then
    table.insert(lines, "")
    table.insert(lines, colors.feature .. "🧩 Custom Filter:" .. colors.normal)
    table.insert(lines, "  " .. colors.highlight .. M.active_filters.custom_filter .. colors.normal)
  end
  
  -- Add footer with no filters message if needed
  if #M.active_filters.extensions == 0 and #M.active_filters.patterns == 0 and 
     not M.active_filters.custom_filter and
     M.active_filters.show_dotfiles and M.active_filters.show_gitignored then
    table.insert(lines, "")
    table.insert(lines, colors.inactive .. "No active filters - showing all files" .. colors.normal)
  end
  
  table.insert(lines, colors.title .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━" .. colors.normal)
  
  -- Display in floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Calculate dimensions
  local width = 50
  local height = #lines
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Filter Status ",
    title_pos = "center",
  }
  
  local win = vim.api.nvim_open_win(buf, true, opts)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  
  -- Close on any key
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<Cmd>close<CR>", {noremap = true, silent = true})
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<Cmd>close<CR>", {noremap = true, silent = true})
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "<Cmd>close<CR>", {noremap = true, silent = true})
  vim.api.nvim_buf_set_keymap(buf, "n", "<Space>", "<Cmd>close<CR>", {noremap = true, silent = true})
end

-- Create a submenu for filter operations
function M.create_filter_submenu(node)
  -- Create colorful status indicators
  local dotfiles_status = M.active_filters.show_dotfiles and 
                        icons.toggle_on .. " Shown" or 
                        icons.toggle_off .. " Hidden"
  
  local gitignored_status = M.active_filters.show_gitignored and 
                          icons.toggle_on .. " Shown" or 
                          icons.toggle_off .. " Hidden"
  
  local ext_count = #M.active_filters.extensions
  local ext_status = ext_count > 0 and 
                    "(" .. ext_count .. " active)" or 
                    "(None)"
  
  local pattern_count = #M.active_filters.patterns
  local pattern_status = pattern_count > 0 and 
                        "(" .. pattern_count .. " active)" or 
                        "(None)"
  
  local preset_count = vim.tbl_count(M.filter_presets)
  local preset_status = preset_count > 0 and 
                      "(" .. preset_count .. " saved)" or 
                      "(None)"
  
  -- Menu items with status indicators
  local items = {
    { "Toggle Dotfiles " .. dotfiles_status, function() M.toggle_dotfiles() end },
    { "Toggle Git Ignored Files " .. gitignored_status, function() M.toggle_gitignored() end },
    { "Filter by Extension " .. ext_status, function() M.filter_by_extension() end },
    { "Remove Extension Filter " .. ext_status, function() M.remove_extension_filter() end },
    { "Filter by Pattern " .. pattern_status, function() M.filter_by_pattern() end },
    { "Remove Pattern Filter " .. pattern_status, function() M.remove_pattern_filter() end },
    { "Save Filter Preset " .. preset_status, function() M.save_filter_preset() end },
    { "Load Filter Preset " .. preset_status, function() M.load_filter_preset() end },
    { "Delete Filter Preset " .. preset_status, function() M.delete_filter_preset() end },
    { "Show Active Filters", function() M.show_active_filters() end },
    { "Reset All Filters", function() M.reset_filters() end },
  }
  
  -- Custom colorful hover effect for items
  return {
    title = "Filter Operations",
    icon = "🔍 ",
    items = items,
    item_icon = function(title)
      if string.match(title, "Toggle Dotfiles") then
        return M.active_filters.show_dotfiles and "🟢 " or "🔴 "
      elseif string.match(title, "Toggle Git") then
        return M.active_filters.show_gitignored and "🟢 " or "🔴 "
      elseif string.match(title, "Extension") and string.match(title, "Filter by") then
        return "📄 "
      elseif string.match(title, "Extension") and string.match(title, "Remove") then
        return "🗑️ "
      elseif string.match(title, "Pattern") and string.match(title, "Filter by") then
        return "🔣 "
      elseif string.match(title, "Pattern") and string.match(title, "Remove") then
        return "🗑️ "
      elseif string.match(title, "Save") then
        return "💾 "
      elseif string.match(title, "Load") then
        return "📂 "
      elseif string.match(title, "Delete") then
        return "🗑️ "
      elseif string.match(title, "Show") then
        return "👁️ "
      elseif string.match(title, "Reset") then
        return "🔄 "
      else
        return "🔍 "
      end
    end
  }
end

-- Initialize the module
init()

return M 