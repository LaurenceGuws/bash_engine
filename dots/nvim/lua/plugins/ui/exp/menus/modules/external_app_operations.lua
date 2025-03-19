-- External Application Operations Module for NvimTree Context Menu
-- Provides integration with external applications

local M = {}

-- Check if a command exists
local function command_exists(cmd)
  local handle = io.popen("which " .. cmd .. " 2>/dev/null")
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

-- Detect available applications
local function detect_applications()
  local apps = {
    -- File managers
    file_manager = {
      { cmd = "nautilus", name = "Nautilus (GNOME)" },
      { cmd = "dolphin", name = "Dolphin (KDE)" },
      { cmd = "thunar", name = "Thunar (XFCE)" },
      { cmd = "pcmanfm", name = "PCManFM" },
      { cmd = "nemo", name = "Nemo (Cinnamon)" },
      { cmd = "ranger", name = "Ranger (Terminal)" },
    },
    -- Terminals
    terminal = {
      { cmd = "gnome-terminal", name = "GNOME Terminal" },
      { cmd = "konsole", name = "Konsole (KDE)" },
      { cmd = "xfce4-terminal", name = "XFCE Terminal" },
      { cmd = "alacritty", name = "Alacritty" },
      { cmd = "kitty", name = "Kitty" },
      { cmd = "urxvt", name = "URxvt" },
      { cmd = "terminology", name = "Terminology" },
      { cmd = "st", name = "Simple Terminal" },
    },
    -- Text editors
    text_editor = {
      { cmd = "subl", name = "Sublime Text" },
      { cmd = "code", name = "Visual Studio Code" },
      { cmd = "atom", name = "Atom" },
      { cmd = "gedit", name = "Gedit" },
      { cmd = "kate", name = "Kate" },
      { cmd = "mousepad", name = "Mousepad" },
      { cmd = "gvim", name = "GVim" },
      { cmd = "emacs", name = "Emacs" },
    },
    -- Web browsers
    browser = {
      { cmd = "firefox", name = "Firefox" },
      { cmd = "google-chrome", name = "Google Chrome" },
      { cmd = "chromium", name = "Chromium" },
      { cmd = "epiphany", name = "GNOME Web" },
      { cmd = "opera", name = "Opera" },
      { cmd = "brave", name = "Brave" },
    },
    -- Image viewers
    image_viewer = {
      { cmd = "eog", name = "Eye of GNOME" },
      { cmd = "gwenview", name = "Gwenview" },
      { cmd = "ristretto", name = "Ristretto" },
      { cmd = "feh", name = "Feh" },
      { cmd = "gimp", name = "GIMP" },
    },
    -- Document viewers
    document_viewer = {
      { cmd = "evince", name = "Evince" },
      { cmd = "okular", name = "Okular" },
      { cmd = "zathura", name = "Zathura" },
      { cmd = "xpdf", name = "Xpdf" },
      { cmd = "libreoffice", name = "LibreOffice" },
    },
    -- Media players
    media_player = {
      { cmd = "vlc", name = "VLC" },
      { cmd = "mpv", name = "MPV" },
      { cmd = "totem", name = "Totem" },
      { cmd = "audacious", name = "Audacious" },
      { cmd = "rhythmbox", name = "Rhythmbox" },
    },
  }
  
  -- Check which applications are available
  local available_apps = {}
  for category, app_list in pairs(apps) do
    available_apps[category] = {}
    for _, app in ipairs(app_list) do
      if command_exists(app.cmd) then
        table.insert(available_apps[category], app)
      end
    end
  end
  
  return available_apps
end

-- Open in file manager
function M.open_in_file_manager(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  local apps = detect_applications().file_manager
  if #apps == 0 then
    vim.notify("No file manager found", vim.log.levels.ERROR)
    return
  end
  
  -- If only one file manager is available, use it
  if #apps == 1 then
    local cmd = apps[1].cmd .. " " .. vim.fn.shellescape(node.absolute_path)
    vim.fn.jobstart(cmd, {
      detach = true,
      on_exit = function(_, exit_code)
        if exit_code ~= 0 then
          vim.notify("Failed to open file manager", vim.log.levels.ERROR)
        end
      end,
    })
    return
  end
  
  -- Otherwise, let the user choose
  local app_names = {}
  for i, app in ipairs(apps) do
    table.insert(app_names, i .. ": " .. app.name)
  end
  
  vim.ui.select(app_names, {
    prompt = "Select file manager:",
    format_item = function(item) return item end,
  }, function(choice, idx)
    if not choice then return end
    
    local app = apps[idx]
    local cmd = app.cmd .. " " .. vim.fn.shellescape(node.absolute_path)
    vim.fn.jobstart(cmd, {
      detach = true,
      on_exit = function(_, exit_code)
        if exit_code ~= 0 then
          vim.notify("Failed to open file manager", vim.log.levels.ERROR)
        end
      end,
    })
  end)
end

-- Open terminal in directory
function M.open_terminal_here(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  local path
  if node.fs_stat and node.fs_stat.type == "directory" then
    path = node.absolute_path
  else
    path = vim.fn.fnamemodify(node.absolute_path, ":h")
  end
  
  local apps = detect_applications().terminal
  if #apps == 0 then
    vim.notify("No terminal found", vim.log.levels.ERROR)
    return
  end
  
  -- If only one terminal is available, use it
  if #apps == 1 then
    local cmd
    if apps[1].cmd == "gnome-terminal" then
      cmd = apps[1].cmd .. " --working-directory=" .. vim.fn.shellescape(path)
    elseif apps[1].cmd == "konsole" then
      cmd = apps[1].cmd .. " --workdir " .. vim.fn.shellescape(path)
    elseif apps[1].cmd == "xfce4-terminal" then
      cmd = apps[1].cmd .. " --working-directory=" .. vim.fn.shellescape(path)
    else
      cmd = apps[1].cmd .. " --working-directory " .. vim.fn.shellescape(path)
    end
    
    vim.fn.jobstart(cmd, {
      detach = true,
      on_exit = function(_, exit_code)
        if exit_code ~= 0 then
          vim.notify("Failed to open terminal", vim.log.levels.ERROR)
        end
      end,
    })
    return
  end
  
  -- Otherwise, let the user choose
  local app_names = {}
  for i, app in ipairs(apps) do
    table.insert(app_names, i .. ": " .. app.name)
  end
  
  vim.ui.select(app_names, {
    prompt = "Select terminal:",
    format_item = function(item) return item end,
  }, function(choice, idx)
    if not choice then return end
    
    local app = apps[idx]
    local cmd
    if app.cmd == "gnome-terminal" then
      cmd = app.cmd .. " --working-directory=" .. vim.fn.shellescape(path)
    elseif app.cmd == "konsole" then
      cmd = app.cmd .. " --workdir " .. vim.fn.shellescape(path)
    elseif app.cmd == "xfce4-terminal" then
      cmd = app.cmd .. " --working-directory=" .. vim.fn.shellescape(path)
    else
      cmd = app.cmd .. " --working-directory " .. vim.fn.shellescape(path)
    end
    
    vim.fn.jobstart(cmd, {
      detach = true,
      on_exit = function(_, exit_code)
        if exit_code ~= 0 then
          vim.notify("Failed to open terminal", vim.log.levels.ERROR)
        end
      end,
    })
  end)
end

-- Open with default application
function M.open_with_default_app(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  -- Check if xdg-open exists
  if not command_exists("xdg-open") then
    vim.notify("xdg-open command not found", vim.log.levels.ERROR)
    return
  end
  
  -- Open with xdg-open
  local cmd = "xdg-open " .. vim.fn.shellescape(node.absolute_path)
  vim.fn.jobstart(cmd, {
    detach = true,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.notify("Failed to open with default application", vim.log.levels.ERROR)
      end
    end,
  })
end

-- Open with specific application
function M.open_with_specific_app(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  -- Determine file type based on extension
  local extension = string.match(node.name, "%.([^%.]+)$") or ""
  extension = string.lower(extension)
  
  local app_category
  if extension == "txt" or extension == "md" or extension == "lua" or extension == "py" or extension == "js" or extension == "html" or extension == "css" or extension == "json" or extension == "xml" or extension == "yml" or extension == "yaml" or extension == "toml" or extension == "conf" or extension == "ini" or extension == "sh" then
    app_category = "text_editor"
  elseif extension == "jpg" or extension == "jpeg" or extension == "png" or extension == "gif" or extension == "svg" or extension == "bmp" then
    app_category = "image_viewer"
  elseif extension == "pdf" or extension == "doc" or extension == "docx" or extension == "odt" or extension == "rtf" then
    app_category = "document_viewer"
  elseif extension == "mp4" or extension == "mkv" or extension == "avi" or extension == "mov" or extension == "mp3" or extension == "ogg" or extension == "flac" or extension == "wav" then
    app_category = "media_player"
  elseif extension == "htm" or extension == "html" then
    app_category = "browser"
  else
    app_category = "text_editor" -- Default to text editor for unknown types
  end
  
  local apps = detect_applications()[app_category]
  if #apps == 0 then
    vim.notify("No suitable application found for this file type", vim.log.levels.ERROR)
    return
  end
  
  -- Let the user choose
  local app_names = {}
  for i, app in ipairs(apps) do
    table.insert(app_names, i .. ": " .. app.name)
  end
  
  vim.ui.select(app_names, {
    prompt = "Select application to open with:",
    format_item = function(item) return item end,
  }, function(choice, idx)
    if not choice then return end
    
    local app = apps[idx]
    local cmd = app.cmd .. " " .. vim.fn.shellescape(node.absolute_path)
    vim.fn.jobstart(cmd, {
      detach = true,
      on_exit = function(_, exit_code)
        if exit_code ~= 0 then
          vim.notify("Failed to open with " .. app.name, vim.log.levels.ERROR)
        end
      end,
    })
  end)
end

-- View file using less (or alternative pager)
function M.view_in_pager(node)
  if not node or not node.absolute_path then
    vim.notify("Invalid node", vim.log.levels.ERROR)
    return
  end
  
  -- Check if this is a text file or binary
  local stat = vim.loop.fs_stat(node.absolute_path)
  if not stat then
    vim.notify("Could not get file stats", vim.log.levels.ERROR)
    return
  end
  
  if stat.type ~= "file" then
    vim.notify("Not a regular file", vim.log.levels.ERROR)
    return
  end
  
  -- Try to determine if this is a binary file
  local cmd = "file --mime-encoding " .. vim.fn.shellescape(node.absolute_path)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  
  if result:match("binary") then
    vim.notify("This appears to be a binary file", vim.log.levels.WARN)
    -- Ask if they still want to view it
    vim.ui.select({"Yes", "No"}, {
      prompt = "View binary file anyway?",
    }, function(choice)
      if choice == "Yes" then
        M.do_view_in_pager(node.absolute_path)
      end
    end)
  else
    M.do_view_in_pager(node.absolute_path)
  end
end

-- Actual pager implementation
function M.do_view_in_pager(path)
  -- Check if less exists, fall back to more
  local pager = "less"
  if not command_exists("less") then
    if command_exists("more") then
      pager = "more"
    else
      vim.notify("No pager found (less or more)", vim.log.levels.ERROR)
      return
    end
  end
  
  -- Open a terminal buffer with the pager
  vim.cmd("botright new")
  vim.cmd("terminal " .. pager .. " " .. vim.fn.shellescape(path))
  vim.cmd("startinsert")
  
  -- Set buffer options
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(buf, "buflisted", false)
  vim.api.nvim_buf_set_name(buf, "Pager: " .. path)
  
  -- Map q to close the buffer
  vim.api.nvim_buf_set_keymap(buf, "t", "q", "<C-\\><C-n>:q<CR>", {
    noremap = true,
    silent = true,
  })
end

-- Create a submenu for external application operations
function M.create_external_app_submenu(node, is_folder)
  if not node then return nil end
  
  local items = {
    { "Open with Default Application", function() M.open_with_default_app(node) end },
    { "Open with Specific Application", function() M.open_with_specific_app(node) end },
  }
  
  -- Add file manager and terminal options
  table.insert(items, { "Open in File Manager", function() M.open_in_file_manager(node) end })
  table.insert(items, { "Open Terminal Here", function() M.open_terminal_here(node) end })
  
  -- Add view in pager only for files
  if not is_folder then
    table.insert(items, { "View in Pager", function() M.view_in_pager(node) end })
  end
  
  return {
    title = "External Applications",
    icon = "🔗 ",
    items = items,
    item_icon = function(title)
      if string.match(title, "Default") then
        return "🚀 "
      elseif string.match(title, "Specific") then
        return "📎 "
      elseif string.match(title, "File Manager") then
        return "📂 "
      elseif string.match(title, "Terminal") then
        return "📟 "
      elseif string.match(title, "Pager") then
        return "📄 "
      else
        return "🔗 "
      end
    end
  }
end

return M 