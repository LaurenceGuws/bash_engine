-- Search Operations Module for NvimTree
-- Contains advanced search functionality for files and content

local M = {}

-- Find files with FZF
function M.find_files(node, is_folder, fzf_lua)
  local target = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  fzf_lua.files({ 
    cwd = target,
    prompt = "Find Files > ",
  })
end

-- Live grep with FZF for searching file content
function M.live_grep(node, is_folder, fzf_lua)
  local target = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  fzf_lua.live_grep({ 
    cwd = target,
    prompt = "Search Content > ",
  })
end

-- Grep for word under cursor
function M.grep_word(node, is_folder, fzf_lua)
  local target = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  
  -- Ask for word to search
  vim.ui.input({ prompt = "Search for word: " }, function(word)
    if not word or word == "" then return end
    
    fzf_lua.grep({ 
      cwd = target,
      search = word,
      prompt = "Grep: " .. word .. " > ",
    })
  end)
end

-- Find files by extension
function M.find_by_extension(node, is_folder, fzf_lua)
  local target = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  
  -- Use the current file's extension as default if not a folder
  local default_ext = ""
  if not is_folder then
    default_ext = vim.fn.fnamemodify(node.name, ":e")
  end
  
  -- Ask for extension
  vim.ui.input({ prompt = "Extension: ", default = default_ext }, function(ext)
    if not ext or ext == "" then return end
    
    -- Remove dot if user included it
    ext = ext:gsub("^%.", "")
    
    -- Create glob pattern
    local pattern = "*." .. ext
    
    fzf_lua.files({ 
      cwd = target,
      prompt = "Find *." .. ext .. " > ",
      file_icons = true,
      file_ignore_patterns = {"[^.].*%." .. ext .. "$"},
    })
    
    -- Notify for clarity
    vim.notify("Searching for files with extension: " .. ext, vim.log.levels.INFO)
  end)
end

-- Find recent files in this directory
function M.find_recent_files(node, is_folder, fzf_lua)
  local target = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  
  -- Execute find command to get recent files
  local cmd = string.format("find %s -type f -not -path '*/\\.*' -mtime -7 | sort -r", vim.fn.shellescape(target))
  local handle = io.popen(cmd)
  
  if not handle then
    vim.notify("Failed to run find command", vim.log.levels.ERROR)
    return
  end
  
  local result = handle:read("*a")
  handle:close()
  
  -- Split into lines
  local lines = {}
  for line in result:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  
  -- Display results with FZF
  fzf_lua.fzf_exec(lines, {
    prompt = "Recent Files > ",
    actions = {
      ["default"] = function(selected)
        if selected and selected[1] then
          vim.cmd("edit " .. vim.fn.fnameescape(selected[1]))
        end
      end,
    },
    winopts = {
      height = 0.7,
      width = 0.7,
      preview = {
        layout = "vertical",
        vertical = "down:65%",
      },
    },
  })
end

-- Create a submenu for search operations
function M.create_search_submenu(node, is_folder, fzf_lua)
  local search_items = {}
  
  -- Add search operations
  table.insert(search_items, { "Find Files", function() M.find_files(node, is_folder, fzf_lua) end })
  table.insert(search_items, { "Search File Content", function() M.live_grep(node, is_folder, fzf_lua) end })
  table.insert(search_items, { "Grep for Word", function() M.grep_word(node, is_folder, fzf_lua) end })
  table.insert(search_items, { "Find Files by Extension", function() M.find_by_extension(node, is_folder, fzf_lua) end })
  table.insert(search_items, { "Recently Modified Files", function() M.find_recent_files(node, is_folder, fzf_lua) end })
  
  -- Format and return the menu
  return {
    title = "Search Operations",
    icon = "🔍",
    items = search_items,
    item_icon = "󰍉 ",
    prompt = "Search Operations > ",
    window_title = "🔍 Search: " .. (node.name or "")
  }
end

return M 