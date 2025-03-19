-- File Operations Module for NvimTree
-- Contains all file-related operations including create, symlink, and open with

local M = {}

-- Create a file with template
function M.create_file_with_template(node, is_folder, api, fzf_lua)
  -- List of common templates
  local templates = {
    "Empty File", 
    "HTML Template",
    "Python Script",
    "Lua Module",
    "Markdown Document",
    "JSON Configuration",
    "YAML Configuration",
    "Shell Script",
  }
  
  -- Prompt for template type first
  fzf_lua.fzf_exec(templates, {
    prompt = "Select Template > ",
    actions = {
      ["default"] = function(selected)
        if selected and selected[1] then
          local template_type = selected[1]
          
          -- Now prompt for filename
          vim.ui.input({ prompt = "Enter filename: " }, function(filename)
            if not filename or filename == "" then return end
            
            -- Get the directory path (either the selected folder or parent dir)
            local dir_path = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
            local full_path = dir_path .. "/" .. filename
            
            -- Content based on template type
            local content = ""
            if template_type == "HTML Template" then
              content = "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n  <meta charset=\"UTF-8\">\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n  <title>Document</title>\n</head>\n<body>\n  \n</body>\n</html>"
            elseif template_type == "Python Script" then
              content = "#!/usr/bin/env python3\n\ndef main():\n    pass\n\nif __name__ == \"__main__\":\n    main()"
            elseif template_type == "Lua Module" then
              content = "local M = {}\n\nfunction M.setup(opts)\n  opts = opts or {}\n  \n  -- Your code here\n  \nend\n\nreturn M"
            elseif template_type == "Markdown Document" then
              content = "# " .. vim.fn.fnamemodify(filename, ":r") .. "\n\n## Overview\n\n## Contents\n\n## Details\n"
            elseif template_type == "JSON Configuration" then
              content = "{\n  \"name\": \"project\",\n  \"version\": \"1.0.0\",\n  \"description\": \"\",\n  \"main\": \"index.js\",\n  \"scripts\": {\n    \"test\": \"echo \\\"Error: no test specified\\\" && exit 1\"\n  },\n  \"keywords\": [],\n  \"author\": \"\",\n  \"license\": \"MIT\"\n}"
            elseif template_type == "YAML Configuration" then
              content = "---\nname: project\nversion: 1.0.0\ndescription: ''\nmain: index.js\nscripts:\n  test: 'echo \"Error: no test specified\" && exit 1'\nkeywords: []\nauthor: ''\nlicense: MIT\n"
            elseif template_type == "Shell Script" then
              content = "#!/bin/bash\n\n# Description: \n# Author: \n\nset -e\n\n# Your code here\n"
            end
            
            -- Create the file
            vim.fn.writefile(vim.split(content, "\n"), full_path)
            
            -- Make scripts executable if needed
            if template_type == "Shell Script" or template_type == "Python Script" then
              vim.fn.system("chmod +x " .. vim.fn.shellescape(full_path))
            end
            
            -- Refresh NvimTree
            api.tree.reload()
            
            vim.notify("Created file: " .. filename, vim.log.levels.INFO)
          end)
        end
      end,
    },
    winopts = {
      relative = "cursor",
      row = 1,
      col = 1,
      width = 30,
      height = 12,
      border = "rounded",
      title = "🧩 Select Template",
      inert = true,
    },
  })
end

-- Create a symlink to the current file/folder
function M.create_symlink(node, api)
  -- Copy the current node path
  local source_path = node.absolute_path
  
  -- Ask for target directory
  vim.ui.input({ prompt = "Enter target directory: " }, function(target_dir)
    if not target_dir or target_dir == "" then return end
    
    -- Expand the target directory path
    target_dir = vim.fn.expand(target_dir)
    
    -- Make sure target directory exists
    if vim.fn.isdirectory(target_dir) ~= 1 then
      vim.notify("Target directory does not exist", vim.log.levels.ERROR)
      return
    end
    
    -- Create the symlink
    local target_path = target_dir .. "/" .. node.name
    local cmd = string.format("ln -s %s %s", vim.fn.shellescape(source_path), vim.fn.shellescape(target_path))
    local result = vim.fn.system(cmd)
    
    if vim.v.shell_error == 0 then
      vim.notify("Created symlink at " .. target_path, vim.log.levels.INFO)
      -- Refresh NvimTree to show the new symlink if in the same directory
      api.tree.reload()
    else
      vim.notify("Failed to create symlink: " .. result, vim.log.levels.ERROR)
    end
  end)
end

-- Open file with external application
function M.open_with_app(node, fzf_lua)
  -- Only for files, not folders
  if node.fs_stat and node.fs_stat.type == "directory" then
    vim.notify("Can only open files with external applications", vim.log.levels.WARN)
    return
  end
  
  -- List of common applications
  local apps = {
    "System Default",
    "Visual Studio Code",
    "Firefox",
    "Chrome",
    "GIMP",
    "Custom Command..."
  }
  
  -- Prompt for application
  fzf_lua.fzf_exec(apps, {
    prompt = "Open With > ",
    actions = {
      ["default"] = function(selected)
        if selected and selected[1] then
          local app = selected[1]
          local cmd = ""
          
          if app == "System Default" then
            cmd = string.format("xdg-open %s", vim.fn.shellescape(node.absolute_path))
          elseif app == "Visual Studio Code" then
            cmd = string.format("code %s", vim.fn.shellescape(node.absolute_path))
          elseif app == "Firefox" then
            cmd = string.format("firefox %s", vim.fn.shellescape(node.absolute_path))
          elseif app == "Chrome" then
            cmd = string.format("google-chrome %s", vim.fn.shellescape(node.absolute_path))
          elseif app == "GIMP" then
            cmd = string.format("gimp %s", vim.fn.shellescape(node.absolute_path))
          elseif app == "Custom Command..." then
            vim.ui.input({ prompt = "Enter command (file path will be appended): " }, function(custom_cmd)
              if custom_cmd and custom_cmd ~= "" then
                cmd = string.format("%s %s", custom_cmd, vim.fn.shellescape(node.absolute_path))
                vim.fn.jobstart(cmd, {detach = true})
                vim.notify("File opened with: " .. custom_cmd, vim.log.levels.INFO)
              end
            end)
            return
          end
          
          if cmd ~= "" then
            vim.fn.jobstart(cmd, {detach = true})
            vim.notify("File opened with: " .. app, vim.log.levels.INFO)
          end
        end
      end,
    },
    winopts = {
      relative = "cursor",
      row = 1,
      col = 1,
      width = 30,
      height = 10,
      border = "rounded",
      title = "📂 Open With",
      inert = true,
    },
  })
end

-- Create a submenu with all file operations
function M.create_file_operations_menu(node, is_folder, api, fzf_lua)
  local file_items = {}
  
  -- Add template creation
  table.insert(file_items, { "Create with Template", function()
    M.create_file_with_template(node, is_folder, api, fzf_lua)
  end })
  
  -- Add symlink creation
  table.insert(file_items, { "Create Symlink", function()
    M.create_symlink(node, api)
  end })
  
  -- Add open with for files
  if not is_folder then
    table.insert(file_items, { "Open With...", function()
      M.open_with_app(node, fzf_lua)
    end })
  end
  
  -- Format and return the menu
  return {
    title = "File Operations",
    icon = "📂",
    items = file_items,
    item_icon = function(title)
      if string.match(title, "Create") then return "󰙴 "
      elseif string.match(title, "Symlink") then return "󰌹 "
      elseif string.match(title, "Open") then return "󰏌 "
      else return "📄 " end
    end,
    prompt = "File Operations > ",
    window_title = "📂 File Ops: " .. (node.name or "")
  }
end

return M 