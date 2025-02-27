local git_blame_enabled = false
local ns_id = vim.api.nvim_create_namespace("git_blame_hints")

local function show_git_blame()
  if not git_blame_enabled then
    vim.schedule(function()
      vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end)
    return
  end

  local line = vim.fn.line(".")
  local file = vim.fn.expand("%")

  -- Check if the file is tracked
  local is_tracked = vim.fn.system("git ls-files --error-unmatch " .. file .. " 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    vim.schedule(function()
      vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
      vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, 0, {
        virt_text = { { "   Untracked file", "WarningMsg" } },
        virt_text_pos = "eol",
      })
    end)
    return
  end

  -- Run Git blame asynchronously
  vim.system(
    { "git", "blame", "-L", line .. "," .. line, "--", file, "--porcelain" },
    { text = true },
    function(result)
      local output = result.stdout

      -- Extract author name
      local blame_info = output:match("%((.-) %d%d%d%d%-%d%d%-%d%d") -- Extracts "Author Name"
      if not blame_info or blame_info:match("^Not Committed Yet") then
        blame_info = "Uncommitted changes"
      end

      -- Use vim.schedule() to prevent async issues
      vim.schedule(function()
        vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
        vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, 0, {
          virt_text = { { "   " .. blame_info, "Comment" } },
          virt_text_pos = "eol",
        })
      end)
    end
  )
end

-- Auto-update blame info when moving the cursor
vim.api.nvim_create_autocmd({ "CursorMoved" }, {
  pattern = "*",
  callback = function()
    if git_blame_enabled then
      show_git_blame()
    end
  end,
})

-- Keymap to toggle Git blame hints
vim.keymap.set("n", "<leader>tgb", function()
  git_blame_enabled = not git_blame_enabled

  if git_blame_enabled then
    vim.notify("Git Blame Hints Enabled", vim.log.levels.INFO)
    show_git_blame()
  else
    vim.notify("Git Blame Hints Disabled", vim.log.levels.WARN)
    vim.schedule(function()
      vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end)
  end
end, { desc = "Toggle Git Blame Hints" })
