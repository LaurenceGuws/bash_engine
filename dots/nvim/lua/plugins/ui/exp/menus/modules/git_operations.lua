-- Git Operations Module for NvimTree
-- Contains all git-related functionality for repositories and files

local M = {}

-- Git diff for the current file
function M.git_diff_file(node, cwd)
  local current_cwd = cwd or vim.fn.getcwd()
  vim.cmd("cd " .. vim.fn.fnamemodify(node.absolute_path, ":h"))
  vim.cmd("DiffviewOpen -- " .. node.name)
  vim.defer_fn(function() vim.cmd("cd " .. current_cwd) end, 100)
end

-- Git log for the current file
function M.git_log_file(node, fzf_lua, cwd)
  local current_cwd = cwd or vim.fn.getcwd()
  vim.cmd("cd " .. vim.fn.fnamemodify(node.absolute_path, ":h"))
  fzf_lua.git_bcommits({file = node.name})
  vim.defer_fn(function() vim.cmd("cd " .. current_cwd) end, 100)
end

-- Git blame for the current file
function M.git_blame_file(node, fzf_lua, cwd)
  local current_cwd = cwd or vim.fn.getcwd()
  vim.cmd("cd " .. vim.fn.fnamemodify(node.absolute_path, ":h"))
  fzf_lua.git_blame({file = node.name})
  vim.defer_fn(function() vim.cmd("cd " .. current_cwd) end, 100)
end

-- Show git stashes
function M.git_stashes(node, is_folder, fzf_lua, cwd)
  local current_cwd = cwd or vim.fn.getcwd()
  local dir = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  vim.cmd("cd " .. dir)
  fzf_lua.git_stash()
  vim.defer_fn(function() vim.cmd("cd " .. current_cwd) end, 100)
end

-- Show unpushed commits
function M.git_unpushed_commits(node, is_folder, cwd)
  local current_cwd = cwd or vim.fn.getcwd()
  local dir = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  vim.cmd("cd " .. dir)
  vim.cmd("Git log --branches --not --remotes")
  vim.defer_fn(function() vim.cmd("cd " .. current_cwd) end, 100)
end

-- Git status for the repository
function M.git_status(node, is_folder, fzf_lua, cwd)
  local current_cwd = cwd or vim.fn.getcwd()
  local dir = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  vim.cmd("cd " .. dir)
  fzf_lua.git_status()
  vim.defer_fn(function() vim.cmd("cd " .. current_cwd) end, 100)
end

-- Git branches
function M.git_branches(node, is_folder, fzf_lua, cwd)
  local current_cwd = cwd or vim.fn.getcwd()
  local dir = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  vim.cmd("cd " .. dir)
  fzf_lua.git_branches()
  vim.defer_fn(function() vim.cmd("cd " .. current_cwd) end, 100)
end

-- Create a git operations submenu
function M.create_git_submenu(node, is_folder, is_git_repo, fzf_lua)
  if not is_git_repo then return nil end -- Only for git repos
  
  local git_items = {}
  
  -- Current directory for operations
  local cwd = vim.fn.getcwd()
  
  -- File specific operations
  if not is_folder then
    table.insert(git_items, { "Git Diff This File", function() 
      M.git_diff_file(node, cwd)
    end })
    
    table.insert(git_items, { "Git Log This File", function() 
      M.git_log_file(node, fzf_lua, cwd)
    end })
    
    table.insert(git_items, { "Git Blame", function() 
      M.git_blame_file(node, fzf_lua, cwd)
    end })
  end
  
  -- Repository-wide operations
  table.insert(git_items, { "Git Status", function() 
    M.git_status(node, is_folder, fzf_lua, cwd)
  end })
  
  table.insert(git_items, { "Git Branches", function() 
    M.git_branches(node, is_folder, fzf_lua, cwd)
  end })
  
  table.insert(git_items, { "Show Stashes", function() 
    M.git_stashes(node, is_folder, fzf_lua, cwd)
  end })
  
  table.insert(git_items, { "Show Unpushed Commits", function() 
    M.git_unpushed_commits(node, is_folder, cwd)
  end })
  
  -- Format and return the menu
  return {
    title = "Git Operations",
    icon = "󰊢",
    items = git_items,
    item_icon = "󰊢 ",
    prompt = "Git Operations > ",
    window_title = "󰊢 Git: " .. (node.name or "")
  }
end

return M 