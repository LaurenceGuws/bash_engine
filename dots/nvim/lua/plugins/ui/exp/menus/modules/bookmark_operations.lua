-- Bookmark Operations Module for NvimTree
-- Contains functionality for bookmarking files and directories

local M = {}

-- Path for storing bookmarks
local bookmark_file = vim.fn.stdpath("data") .. "/nvim_tree_bookmarks.json"

-- Load bookmarks from file
function M.load_bookmarks()
  local bookmarks = {}
  
  -- Check if the file exists
  if vim.fn.filereadable(bookmark_file) == 1 then
    local content = vim.fn.readfile(bookmark_file)
    local json_str = table.concat(content, "\n")
    
    -- Parse JSON
    local status, result = pcall(vim.fn.json_decode, json_str)
    if status then
      bookmarks = result
    else
      vim.notify("Failed to parse bookmarks file", vim.log.levels.WARN)
    end
  end
  
  return bookmarks
end

-- Save bookmarks to file
function M.save_bookmarks(bookmarks)
  -- Convert to JSON
  local status, json_str = pcall(vim.fn.json_encode, bookmarks)
  if not status then
    vim.notify("Failed to encode bookmarks to JSON", vim.log.levels.ERROR)
    return false
  end
  
  -- Write to file
  local result = vim.fn.writefile({json_str}, bookmark_file)
  if result == -1 then
    vim.notify("Failed to write bookmarks to file", vim.log.levels.ERROR)
    return false
  end
  
  return true
end

-- Add current node to bookmarks
function M.add_bookmark(node)
  -- Load existing bookmarks
  local bookmarks = M.load_bookmarks()
  
  -- Check if already bookmarked
  for _, bookmark in ipairs(bookmarks) do
    if bookmark.path == node.absolute_path then
      vim.notify("Already bookmarked: " .. node.name, vim.log.levels.WARN)
      return
    end
  end
  
  -- Ask for optional label
  vim.ui.input({ prompt = "Bookmark label (optional): " }, function(label)
    -- Use file/folder name as default if no label provided
    local bookmark_label = label and label ~= "" and label or node.name
    
    -- Add to bookmarks
    table.insert(bookmarks, {
      path = node.absolute_path,
      name = node.name,
      label = bookmark_label,
      is_dir = node.fs_stat.type == "directory",
      timestamp = os.time()
    })
    
    -- Save bookmarks
    if M.save_bookmarks(bookmarks) then
      vim.notify("Bookmarked: " .. bookmark_label, vim.log.levels.INFO)
    end
  end)
end

-- Remove a bookmark
function M.remove_bookmark(node)
  -- Load existing bookmarks
  local bookmarks = M.load_bookmarks()
  
  -- Find the bookmark for this path
  local found = false
  for i, bookmark in ipairs(bookmarks) do
    if bookmark.path == node.absolute_path then
      table.remove(bookmarks, i)
      found = true
      break
    end
  end
  
  if found then
    -- Save updated bookmarks
    if M.save_bookmarks(bookmarks) then
      vim.notify("Removed bookmark: " .. node.name, vim.log.levels.INFO)
    end
  else
    vim.notify("Not bookmarked: " .. node.name, vim.log.levels.WARN)
  end
end

-- Open a bookmark in NvimTree
function M.goto_bookmark(bookmark, api)
  if vim.fn.isdirectory(bookmark.path) == 1 or vim.fn.filereadable(bookmark.path) == 1 then
    -- If it's a directory, change to it first
    if bookmark.is_dir then
      vim.cmd("cd " .. vim.fn.fnameescape(bookmark.path))
    end
    
    -- Reveal in NvimTree
    api.tree.find_file(bookmark.path)
    
    -- If it's a file, also open it
    if not bookmark.is_dir then
      vim.cmd("edit " .. vim.fn.fnameescape(bookmark.path))
    end
  else
    vim.notify("Bookmark target no longer exists: " .. bookmark.path, vim.log.levels.WARN)
    
    -- Offer to remove invalid bookmark
    vim.ui.select({"Yes", "No"}, {
      prompt = "Remove invalid bookmark?",
    }, function(choice)
      if choice == "Yes" then
        local bookmarks = M.load_bookmarks()
        
        -- Find and remove the invalid bookmark
        for i, bm in ipairs(bookmarks) do
          if bm.path == bookmark.path then
            table.remove(bookmarks, i)
            break
          end
        end
        
        -- Save updated bookmarks
        M.save_bookmarks(bookmarks)
      end
    end)
  end
end

-- List all bookmarks with FZF
function M.show_bookmarks(api, fzf_lua)
  -- Load bookmarks
  local bookmarks = M.load_bookmarks()
  
  if #bookmarks == 0 then
    vim.notify("No bookmarks found", vim.log.levels.INFO)
    return
  end
  
  -- Format bookmarks for display
  local formatted_bookmarks = {}
  local actions = {}
  
  for i, bookmark in ipairs(bookmarks) do
    local icon = bookmark.is_dir and "📁 " or "📄 "
    local text = string.format("%s%s (%s)", icon, bookmark.label, bookmark.path)
    table.insert(formatted_bookmarks, text)
    actions[text] = bookmark
  end
  
  -- Show bookmarks with FZF
  fzf_lua.fzf_exec(formatted_bookmarks, {
    prompt = "Bookmarks > ",
    actions = {
      ["default"] = function(selected)
        if selected and selected[1] then
          local bookmark = actions[selected[1]]
          if bookmark then
            M.goto_bookmark(bookmark, api)
          end
        end
      end,
      ["ctrl-x"] = function(selected)
        if selected and selected[1] then
          local bookmark = actions[selected[1]]
          if bookmark then
            -- Create a fake node for removal
            local fake_node = {
              absolute_path = bookmark.path,
              name = bookmark.name
            }
            M.remove_bookmark(fake_node)
            
            -- Refresh the bookmark list
            vim.defer_fn(function()
              M.show_bookmarks(api, fzf_lua)
            end, 100)
          end
        end
      end
    },
    winopts = {
      height = 0.6,
      width = 0.8,
      preview = {
        layout = "vertical",
        vertical = "down:60%",
      },
    },
  })
end

-- Create a submenu for bookmark operations
function M.create_bookmark_submenu(node, api, fzf_lua)
  local bookmark_items = {}
  
  -- Check if node is bookmarked
  local bookmarks = M.load_bookmarks()
  local is_bookmarked = false
  
  for _, bookmark in ipairs(bookmarks) do
    if bookmark.path == node.absolute_path then
      is_bookmarked = true
      break
    end
  end
  
  -- Add bookmark actions
  if is_bookmarked then
    table.insert(bookmark_items, { "Remove Bookmark", function() M.remove_bookmark(node) end })
  else
    table.insert(bookmark_items, { "Add Bookmark", function() M.add_bookmark(node) end })
  end
  
  -- Show all bookmarks
  table.insert(bookmark_items, { "Show All Bookmarks", function() M.show_bookmarks(api, fzf_lua) end })
  
  -- Format and return the menu
  return {
    title = "Bookmark Operations",
    icon = "🔖",
    items = bookmark_items,
    item_icon = "🔖 ",
    prompt = "Bookmark Operations > ",
    window_title = "🔖 Bookmarks: " .. (node.name or "")
  }
end

return M 