-- Archive Operations Module for NvimTree
-- Contains functionality for working with zip, tar, and other archive formats

local M = {}

-- Check if necessary tools are available
function M.check_tools()
  local tools = {
    zip = vim.fn.executable("zip") == 1,
    unzip = vim.fn.executable("unzip") == 1,
    tar = vim.fn.executable("tar") == 1,
    gzip = vim.fn.executable("gzip") == 1,
  }
  
  return tools
end

-- Extract archive to a directory
function M.extract_archive(node, api)
  if node.fs_stat.type ~= "file" then
    vim.notify("Can only extract file archives", vim.log.levels.WARN)
    return
  end
  
  -- Get file extension
  local name = node.name:lower()
  local ext = vim.fn.fnamemodify(name, ":e")
  local tools = M.check_tools()
  
  -- Check if this is a recognized archive
  local is_archive = false
  local extract_cmd = ""
  
  if name:match("%.zip$") and tools.unzip then
    is_archive = true
    extract_cmd = "unzip"
  elseif name:match("%.tar%.gz$") and tools.tar then
    is_archive = true
    extract_cmd = "tar -xzf"
  elseif name:match("%.tar%.bz2$") and tools.tar then
    is_archive = true
    extract_cmd = "tar -xjf"
  elseif name:match("%.tar$") and tools.tar then
    is_archive = true
    extract_cmd = "tar -xf"
  elseif name:match("%.gz$") and tools.gzip then
    is_archive = true
    extract_cmd = "gunzip"
  end
  
  if not is_archive then
    vim.notify("Unsupported archive format or missing tools", vim.log.levels.WARN)
    return
  end
  
  -- Get target directory (default to the same directory)
  local default_dir = vim.fn.fnamemodify(node.absolute_path, ":h")
  
  vim.ui.input({ 
    prompt = "Extract to directory: ", 
    default = default_dir,
    completion = "dir",
  }, function(target_dir)
    if not target_dir or target_dir == "" then return end
    
    -- Ensure directory exists
    if vim.fn.isdirectory(target_dir) ~= 1 then
      vim.fn.mkdir(target_dir, "p")
    end
    
    -- Build and execute the extract command
    local cmd = ""
    if extract_cmd == "unzip" then
      cmd = string.format("cd %s && unzip %s", 
                         vim.fn.shellescape(target_dir),
                         vim.fn.shellescape(node.absolute_path))
    elseif extract_cmd:match("^tar") then
      cmd = string.format("cd %s && %s %s", 
                         vim.fn.shellescape(target_dir),
                         extract_cmd,
                         vim.fn.shellescape(node.absolute_path))
    elseif extract_cmd == "gunzip" then
      cmd = string.format("cd %s && gunzip -c %s > %s", 
                         vim.fn.shellescape(target_dir),
                         vim.fn.shellescape(node.absolute_path),
                         vim.fn.shellescape(vim.fn.fnamemodify(node.name, ":r")))
    end
    
    -- Execute the command
    vim.fn.jobstart(cmd, {
      on_exit = function(_, code)
        if code == 0 then
          vim.notify("Successfully extracted " .. node.name, vim.log.levels.INFO)
          -- Refresh nvim-tree
          api.tree.reload()
        else
          vim.notify("Failed to extract " .. node.name, vim.log.levels.ERROR)
        end
      end
    })
  end)
end

-- Create new zip archive
function M.create_zip_archive(node, is_folder, api)
  local tools = M.check_tools()
  
  if not tools.zip then
    vim.notify("zip command not available", vim.log.levels.ERROR)
    return
  end
  
  -- Get directory to zip files from
  local source_dir = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  
  -- Ask for archive name
  vim.ui.input({ 
    prompt = "Archive name (will add .zip if missing): ",
    default = is_folder and node.name .. ".zip" or "",
  }, function(archive_name)
    if not archive_name or archive_name == "" then return end
    
    -- Ensure it has .zip extension
    if not archive_name:match("%.zip$") then
      archive_name = archive_name .. ".zip"
    end
    
    -- Determine if we should zip current directory or selected items
    local zip_type = "current_folder"
    
    if is_folder then
      -- If a folder is selected, ask whether to zip its contents or the folder itself
      vim.ui.select({"Zip folder contents", "Zip folder itself"}, {
        prompt = "What to zip:",
      }, function(choice)
        if not choice then return end
        
        zip_type = choice == "Zip folder contents" and "folder_contents" or "folder_itself"
        
        -- Execute the appropriate zip command
        local cmd = ""
        local target_path = source_dir .. "/" .. archive_name
        
        if zip_type == "folder_contents" then
          cmd = string.format("cd %s && zip -r %s *", 
                             vim.fn.shellescape(node.absolute_path),
                             vim.fn.shellescape(target_path))
        else
          local parent_dir = vim.fn.fnamemodify(node.absolute_path, ":h")
          local folder_name = vim.fn.fnamemodify(node.absolute_path, ":t")
          cmd = string.format("cd %s && zip -r %s %s", 
                             vim.fn.shellescape(parent_dir),
                             vim.fn.shellescape(target_path),
                             vim.fn.shellescape(folder_name))
        end
        
        vim.fn.jobstart(cmd, {
          on_exit = function(_, code)
            if code == 0 then
              vim.notify("Successfully created " .. archive_name, vim.log.levels.INFO)
              -- Refresh nvim-tree
              api.tree.reload()
            else
              vim.notify("Failed to create " .. archive_name, vim.log.levels.ERROR)
            end
          end
        })
      end)
    else
      -- For files, just zip the selected file
      local parent_dir = vim.fn.fnamemodify(node.absolute_path, ":h")
      local file_name = vim.fn.fnamemodify(node.absolute_path, ":t")
      local target_path = parent_dir .. "/" .. archive_name
      
      local cmd = string.format("cd %s && zip %s %s", 
                              vim.fn.shellescape(parent_dir),
                              vim.fn.shellescape(target_path),
                              vim.fn.shellescape(file_name))
      
      vim.fn.jobstart(cmd, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("Successfully created " .. archive_name, vim.log.levels.INFO)
            -- Refresh nvim-tree
            api.tree.reload()
          else
            vim.notify("Failed to create " .. archive_name, vim.log.levels.ERROR)
          end
        end
      })
    end
  end)
end

-- Create a submenu for archive operations
function M.create_archive_submenu(node, is_folder, api)
  local archive_items = {}
  local tools = M.check_tools()
  
  -- Check if this is an archive file
  local is_archive = false
  if not is_folder then
    local name = node.name:lower()
    is_archive = name:match("%.zip$") or name:match("%.tar%.gz$") or 
                 name:match("%.tar%.bz2$") or name:match("%.tar$") or
                 name:match("%.gz$")
  end
  
  -- Add extract option for archives
  if is_archive and (tools.unzip or tools.tar or tools.gzip) then
    table.insert(archive_items, { "Extract Archive", function()
      M.extract_archive(node, api)
    end })
  end
  
  -- Add zip creation option
  if tools.zip then
    table.insert(archive_items, { "Create Zip Archive", function()
      M.create_zip_archive(node, is_folder, api)
    end })
  end
  
  -- Only return the menu if we have options
  if #archive_items > 0 then
    return {
      title = "Archive Operations",
      icon = "📦",
      items = archive_items,
      item_icon = "📦 ",
      prompt = "Archive Operations > ",
      window_title = "📦 Archive: " .. (node.name or "")
    }
  else
    return nil
  end
end

return M 