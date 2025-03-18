-- Advanced menu functionality for NvimTree
-- Contains implementations for copy, git, and file operation submenus

local M = {}

-- Copy Operations Submenu 
function M.create_copy_submenu(node, is_folder, api, fzf_lua)
  if is_folder then return nil end -- Only for files

  local copy_items = {}
  
  table.insert(copy_items, { "Copy Name Only", function()
    local name = vim.fn.fnamemodify(node.name, ":r")
    vim.fn.setreg("+", name)
    vim.notify("Copied name to clipboard: " .. name, vim.log.levels.INFO)
  end })
  
  table.insert(copy_items, { "Copy Extension Only", function()
    local ext = vim.fn.fnamemodify(node.name, ":e")
    if ext and ext ~= "" then
      vim.fn.setreg("+", ext)
      vim.notify("Copied extension to clipboard: " .. ext, vim.log.levels.INFO)
    else
      vim.notify("No extension found", vim.log.levels.WARN)
    end
  end })
  
  table.insert(copy_items, { "Copy Relative Path", function()
    local cwd = vim.fn.getcwd()
    local relative_path = node.absolute_path:gsub("^" .. vim.pesc(cwd) .. "/", "")
    vim.fn.setreg("+", relative_path)
    vim.notify("Copied relative path to clipboard: " .. relative_path, vim.log.levels.INFO)
  end })
  
  table.insert(copy_items, { "Copy Directory Path", function()
    local dir = vim.fn.fnamemodify(node.absolute_path, ":h")
    vim.fn.setreg("+", dir)
    vim.notify("Copied directory path to clipboard: " .. dir, vim.log.levels.INFO)
  end })
  
  -- Format and return
  return {
    title = "Copy Operations",
    icon = "📋",
    items = copy_items,
    item_icon = "󰆏 ",
    prompt = "Copy Operations > ",
    window_title = "📋 Copy: " .. (node.name or "")
  }
end

-- Git Operations Submenu
function M.create_git_submenu(node, is_folder, is_git_repo, api, fzf_lua)
  if not is_git_repo then return nil end -- Only for git repos
  
  local git_items = {}
  
  if not is_folder then
    table.insert(git_items, { "Git Diff This File", function()
      local cwd = vim.fn.getcwd()
      vim.cmd("cd " .. vim.fn.fnamemodify(node.absolute_path, ":h"))
      vim.cmd("DiffviewOpen -- " .. node.name)
      vim.defer_fn(function() vim.cmd("cd " .. cwd) end, 100)
    end })
    
    table.insert(git_items, { "Git Log This File", function()
      local cwd = vim.fn.getcwd()
      vim.cmd("cd " .. vim.fn.fnamemodify(node.absolute_path, ":h"))
      fzf_lua.git_bcommits({file = node.name})
      vim.defer_fn(function() vim.cmd("cd " .. cwd) end, 100)
    end })
    
    table.insert(git_items, { "Git Blame", function()
      local cwd = vim.fn.getcwd()
      vim.cmd("cd " .. vim.fn.fnamemodify(node.absolute_path, ":h"))
      fzf_lua.git_blame({file = node.name})
      vim.defer_fn(function() vim.cmd("cd " .. cwd) end, 100)
    end })
  end
  
  -- Repository-wide operations
  table.insert(git_items, { "Show Stashes", function()
    local cwd = vim.fn.getcwd()
    local dir = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
    vim.cmd("cd " .. dir)
    fzf_lua.git_stash()
    vim.defer_fn(function() vim.cmd("cd " .. cwd) end, 100)
  end })
  
  table.insert(git_items, { "Show Unpushed Commits", function()
    local cwd = vim.fn.getcwd()
    local dir = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
    vim.cmd("cd " .. dir)
    vim.cmd("Git log --branches --not --remotes")
    vim.defer_fn(function() vim.cmd("cd " .. cwd) end, 100)
  end })
  
  -- Format and return
  return {
    title = "Git Operations",
    icon = "󰊢",
    items = git_items,
    item_icon = "󰊢 ",
    prompt = "Git Operations > ",
    window_title = "󰊢 Git: " .. (node.name or "")
  }
end

-- File Operations Submenu
function M.create_file_submenu(node, is_folder, api, fzf_lua)
  local file_items = {}
  
  table.insert(file_items, { "Create with Template", function()
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
  end })
  
  table.insert(file_items, { "Create Symlink", function()
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
      else
        vim.notify("Failed to create symlink: " .. result, vim.log.levels.ERROR)
      end
    end)
  end })
  
  if not is_folder then
    table.insert(file_items, { "Open With...", function()
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
    end })
  end
  
  -- Format and return
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

-- Function to create the advanced menu
function M.create_advanced_menu(node, is_folder, is_symlink, is_git_repo, api, fzf_lua)
  local advanced_categories = {}
  
  -- Add available category items
  local copy_submenu = M.create_copy_submenu(node, is_folder, api, fzf_lua)
  if copy_submenu then 
    table.insert(advanced_categories, copy_submenu)
  end
  
  local git_submenu = M.create_git_submenu(node, is_folder, is_git_repo, api, fzf_lua)
  if git_submenu then
    table.insert(advanced_categories, git_submenu)
  end
  
  local file_submenu = M.create_file_submenu(node, is_folder, api, fzf_lua)
  if file_submenu then
    table.insert(advanced_categories, file_submenu)
  end
  
  return advanced_categories
end

-- Helper function to format menu items with icons
function M.format_menu_items(items, icon_fn)
  local formatted_items = {}
  local actions = {}
  
  for i, item in ipairs(items) do
    local title = item[1]
    local icon = type(icon_fn) == "function" and icon_fn(title) or icon_fn or " "
    
    local menu_text = string.format("%s %s", icon, title)
    table.insert(formatted_items, menu_text)
    actions[menu_text] = item[2]
  end
  
  return formatted_items, actions
end

-- Helper to show submenu
function M.show_submenu(params)
  local formatted_items, actions = M.format_menu_items(
    params.items, 
    params.item_icon
  )
  
  params.fzf_lua.fzf_exec(formatted_items, {
    prompt = params.prompt,
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
      height = math.min(#params.items + 2, 15),
      border = "rounded",
      title = params.window_title,
      inert = true,
    },
    fzf_opts = {
      ["--layout"] = "reverse",
      ["--info"] = "inline",
    },
  })
end

return M 