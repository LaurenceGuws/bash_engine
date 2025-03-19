-- Filesystem Operations Module for NvimTree Context Menu
-- Provides advanced filesystem operations

local M = {}

-- Format file permission in Unix-like format
local function format_permissions(mode)
  local permissions = ""
  local mapping = {
    [1] = "x", -- execute/search permission for others
    [2] = "w", -- write permission for others
    [3] = "r", -- read permission for others
    [4] = "x", -- execute/search permission for group
    [5] = "w", -- write permission for group
    [6] = "r", -- read permission for group
    [7] = "x", -- execute/search permission for owner
    [8] = "w", -- write permission for owner
    [9] = "r", -- read permission for owner
  }

  -- Determine file type
  if bit.band(mode, 0xF000) == 0x4000 then
    permissions = permissions .. "d"
  elseif bit.band(mode, 0xF000) == 0xA000 then
    permissions = permissions .. "l"
  else
    permissions = permissions .. "-"
  end

  -- Add permission bits
  for i = 9, 1, -1 do
    if bit.band(mode, bit.lshift(1, i - 1)) ~= 0 then
      permissions = permissions .. mapping[i]
    else
      permissions = permissions .. "-"
    end
  end

  return permissions
end

-- Format time in a readable format
local function format_time(time)
  return os.date("%Y-%m-%d %H:%M:%S", time)
end

-- Format size in a human-readable format
local function format_size(size)
  local sizes = {"B", "KB", "MB", "GB", "TB"}
  local i = 1
  while size > 1024 and i < #sizes do
    size = size / 1024
    i = i + 1
  end
  return string.format("%.2f %s", size, sizes[i])
end

-- Get file stats in a detailed format
local function get_file_stats(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then
    return nil
  end
  
  local result = {
    permissions = format_permissions(stat.mode),
    size = format_size(stat.size),
    accessed = format_time(stat.atime.sec),
    modified = format_time(stat.mtime.sec),
    created = format_time(stat.ctime.sec),
    uid = stat.uid,
    gid = stat.gid,
    type = stat.type,
  }
  
  return result
end

-- Show detailed file information
function M.show_file_details(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  local stats = get_file_stats(node.absolute_path)
  if not stats then
    vim.notify("Could not get file stats", vim.log.levels.ERROR)
    return
  end
  
  local details = {
    "File: " .. node.name,
    "Path: " .. node.absolute_path,
    "Type: " .. stats.type,
    "Permissions: " .. stats.permissions,
    "Size: " .. stats.size,
    "Owner: " .. stats.uid,
    "Group: " .. stats.gid,
    "Last accessed: " .. stats.accessed,
    "Last modified: " .. stats.modified,
    "Created: " .. stats.created,
  }
  
  -- Create a new split to show details
  vim.cmd("botright new")
  vim.cmd("resize 10")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, details)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "buflisted", false)
  vim.api.nvim_buf_set_name(buf, "FileDetails")
  
  -- Close details with 'q'
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", {
    noremap = true,
    silent = true,
  })
end

-- Calculate directory size recursively
function M.calculate_directory_size(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  -- Check if it's a directory
  local stat = vim.loop.fs_stat(node.absolute_path)
  if not stat or stat.type ~= "directory" then
    vim.notify("Not a directory", vim.log.levels.ERROR)
    return
  end
  
  -- Use du command to calculate directory size
  local cmd = "du -sh " .. vim.fn.shellescape(node.absolute_path)
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data and data[1] and data[1] ~= "" then
        local size = string.match(data[1], "^%s*(%S+)")
        vim.notify("Directory size: " .. size, vim.log.levels.INFO)
      end
    end,
    on_stderr = function(_, data)
      if data and data[1] and data[1] ~= "" then
        vim.notify("Error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
      end
    end,
  })
end

-- Change file permissions
function M.change_permissions(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  -- Get current permissions
  local stat = vim.loop.fs_stat(node.absolute_path)
  if not stat then
    vim.notify("Could not get file stats", vim.log.levels.ERROR)
    return
  end
  
  local current_perms = format_permissions(stat.mode)
  
  -- Prompt for new permissions
  vim.ui.input({
    prompt = "Enter new permissions (e.g., 755): ",
    default = "",
  }, function(input)
    if not input or input == "" then
      return
    end
    
    -- Validate input: must be 3 or 4 digits
    if not string.match(input, "^%d%d%d%d?$") then
      vim.notify("Invalid permissions format. Use octal numbers like 755", vim.log.levels.ERROR)
      return
    end
    
    -- Execute chmod command
    local cmd = "chmod " .. input .. " " .. vim.fn.shellescape(node.absolute_path)
    vim.fn.jobstart(cmd, {
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          vim.notify("Permissions changed to " .. input .. " for " .. node.name, vim.log.levels.INFO)
        else
          vim.notify("Failed to change permissions", vim.log.levels.ERROR)
        end
      end,
    })
  end)
end

-- Change file owner
function M.change_owner(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  -- Prompt for new owner
  vim.ui.input({
    prompt = "Enter new owner (user[:group]): ",
    default = "",
  }, function(input)
    if not input or input == "" then
      return
    end
    
    -- Execute chown command
    local cmd = "chown " .. input .. " " .. vim.fn.shellescape(node.absolute_path)
    vim.fn.jobstart(cmd, {
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          vim.notify("Owner changed to " .. input .. " for " .. node.name, vim.log.levels.INFO)
        else
          vim.notify("Failed to change owner", vim.log.levels.ERROR)
        end
      end,
    })
  end)
end

-- Find duplicate files in directory
function M.find_duplicates(node, is_folder)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  local path
  if is_folder then
    path = node.absolute_path
  else
    path = vim.fn.fnamemodify(node.absolute_path, ":h")
  end
  
  -- Use fdupes to find duplicates if available
  vim.fn.jobstart("which fdupes", {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        -- fdupes is available
        local cmd = "fdupes -r " .. vim.fn.shellescape(path)
        
        -- Create a split to show output
        vim.cmd("botright new")
        vim.cmd("resize 15")
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
        vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
        vim.api.nvim_buf_set_name(buf, "Duplicates in " .. path)
        
        vim.fn.jobstart(cmd, {
          on_stdout = function(_, data)
            if data then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
            end
          end,
          on_stderr = function(_, data)
            if data and data[1] and data[1] ~= "" then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"Error: " .. table.concat(data, "\n")})
            end
          end,
          on_exit = function(_, code)
            if code ~= 0 then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"Command failed with code: " .. code})
            end
          end,
        })
        
        -- Close with 'q'
        vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", {
          noremap = true,
          silent = true,
        })
      else
        -- fdupes not available, notify user
        vim.notify("The 'fdupes' command is not available. Please install it first.", vim.log.levels.ERROR)
      end
    end,
  })
end

-- Find large files in directory
function M.find_large_files(node, is_folder)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  local path
  if is_folder then
    path = node.absolute_path
  else
    path = vim.fn.fnamemodify(node.absolute_path, ":h")
  end
  
  -- Prompt for size threshold
  vim.ui.input({
    prompt = "Enter size threshold (e.g., +10M for files > 10MB): ",
    default = "+10M",
  }, function(input)
    if not input or input == "" then
      return
    end
    
    -- Use find command to locate large files
    local cmd = "find " .. vim.fn.shellescape(path) .. " -type f -size " .. input .. " -exec ls -lh {} \\; | sort -k5,5hr"
    
    -- Create a split to show output
    vim.cmd("botright new")
    vim.cmd("resize 15")
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_name(buf, "Large files in " .. path)
    
    vim.fn.jobstart(cmd, {
      on_stdout = function(_, data)
        if data then
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
        end
      end,
      on_stderr = function(_, data)
        if data and data[1] and data[1] ~= "" then
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"Error: " .. table.concat(data, "\n")})
        end
      end,
      on_exit = function(_, code)
        if code ~= 0 then
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"Command failed with code: " .. code})
        end
      end,
    })
    
    -- Close with 'q'
    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", {
      noremap = true,
      silent = true,
    })
  end)
end

-- Create a submenu for filesystem operations
function M.create_filesystem_submenu(node, is_folder)
  if not node then return nil end
  
  local items = {
    { "Show File Details", function() M.show_file_details(node) end },
  }
  
  if is_folder then
    table.insert(items, { "Calculate Directory Size", function() M.calculate_directory_size(node) end })
    table.insert(items, { "Find Duplicate Files", function() M.find_duplicates(node, true) end })
    table.insert(items, { "Find Large Files", function() M.find_large_files(node, true) end })
  else
    table.insert(items, { "Find Duplicate Files (in parent)", function() M.find_duplicates(node, false) end })
    table.insert(items, { "Find Large Files (in parent)", function() M.find_large_files(node, false) end })
  end
  
  -- Add permission and ownership functions
  table.insert(items, { "Change Permissions", function() M.change_permissions(node) end })
  table.insert(items, { "Change Owner", function() M.change_owner(node) end })
  
  return {
    title = "Filesystem Operations",
    icon = "🖴 ",
    items = items,
    item_icon = function(title)
      if string.match(title, "Details") then
        return "📋 "
      elseif string.match(title, "Size") then
        return "📊 "
      elseif string.match(title, "Permissions") then
        return "🔒 "
      elseif string.match(title, "Owner") then
        return "👤 "
      elseif string.match(title, "Duplicate") then
        return "🔍 "
      elseif string.match(title, "Large") then
        return "📈 "
      else
        return "📁 "
      end
    end
  }
end

return M 