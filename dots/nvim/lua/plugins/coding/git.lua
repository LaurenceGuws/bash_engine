return {
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitFilter", "LazyGitCurrentFile" },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      -- Create git blame toggle functionality globally
      -- (separate from on_attach to ensure it's always available)
      local git_blame_enabled = {}  -- Track enabled state per buffer
      local ns_id = vim.api.nvim_create_namespace("git_blame_hints")

      local function show_git_blame()
        local bufnr = vim.api.nvim_get_current_buf()
        if not git_blame_enabled[bufnr] then
          vim.schedule(function()
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
          end)
          return
        end

        local line = vim.fn.line(".")
        local file = vim.fn.expand("%:p")

        -- Check if the file is tracked
        local is_tracked = vim.fn.system("git ls-files --error-unmatch " .. vim.fn.shellescape(file) .. " 2>/dev/null")
        if vim.v.shell_error ~= 0 then
          vim.schedule(function()
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, line - 1, 0, {
              virt_text = { { "   Untracked file", "WarningMsg" } },
              virt_text_pos = "eol",
            })
          end)
          return
        end

        -- Run Git blame asynchronously with a more comprehensive format
        vim.system(
          { "git", "blame", "-L", line .. "," .. line, "--date=short", "--", file },
          { text = true },
          function(result)
            if result.code ~= 0 then return end
            local output = result.stdout

            -- Parse the git blame output
            local author, date, commit_message
            
            -- Not committed yet or similar special case
            if output:match("^0+%s") or output:match("Not Committed Yet") then
              author = "Uncommitted changes"
              date = ""
              commit_message = ""
              
              -- Display immediately with empty commit message
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
                  vim.api.nvim_buf_set_extmark(bufnr, ns_id, line - 1, 0, {
                    virt_text = { { "   " .. author, "Comment" } },
                    virt_text_pos = "eol",
                  })
                end
              end)
            else
              -- Extract all needed information using more complex pattern matching
              author = output:match("%((.-)%s%d%d%d%d%-%d%d%-%d%d") or "Unknown"
              date = output:match("(%d%d%d%d%-%d%d%-%d%d)") or ""
              
              -- To get the commit message, we need to extract the commit hash first
              local commit_hash = output:match("^(%x+)")
              if commit_hash and commit_hash ~= "00000000" then
                -- Use nested vim.system call instead of vim.fn.system
                vim.system(
                  { "git", "show", "-s", "--format=%s", commit_hash },
                  { text = true },
                  function(msg_result)
                    if msg_result.code == 0 then
                      commit_message = msg_result.stdout:gsub("\n", "")
                      
                      -- Truncate commit message if it's too long
                      if #commit_message > 50 then
                        commit_message = commit_message:sub(1, 47) .. "..."
                      end
                    else
                      commit_message = ""
                    end
                    
                    -- Format the blame information
                    local blame_info = author
                    if date ~= "" then
                      blame_info = blame_info .. " (" .. date .. ")"
                    end
                    if commit_message ~= "" then
                      blame_info = blame_info .. " • " .. commit_message
                    end

                    -- Display the blame information
                    vim.schedule(function()
                      if vim.api.nvim_buf_is_valid(bufnr) then
                        vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
                        vim.api.nvim_buf_set_extmark(bufnr, ns_id, line - 1, 0, {
                          virt_text = { { "   " .. blame_info, "Comment" } },
                          virt_text_pos = "eol",
                        })
                      end
                    end)
                  end
                )
              else
                -- No commit hash, just show author and date
                local blame_info = author
                if date ~= "" then
                  blame_info = blame_info .. " (" .. date .. ")"
                end

                vim.schedule(function()
                  if vim.api.nvim_buf_is_valid(bufnr) then
                    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
                    vim.api.nvim_buf_set_extmark(bufnr, ns_id, line - 1, 0, {
                      virt_text = { { "   " .. blame_info, "Comment" } },
                      virt_text_pos = "eol",
                    })
                  end
                end)
              end
            end
          end
        )
      end

      -- Setup toggle keymap (globally available)
      vim.keymap.set("n", "<leader>tgb", function()
        local bufnr = vim.api.nvim_get_current_buf()
        git_blame_enabled[bufnr] = not git_blame_enabled[bufnr]

        if git_blame_enabled[bufnr] then
          vim.notify("Git Blame Hints Enabled", vim.log.levels.INFO)
          show_git_blame()
        else
          vim.notify("Git Blame Hints Disabled", vim.log.levels.WARN)
          vim.schedule(function()
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
          end)
        end
      end, { desc = "Toggle Git Blame Hints" })

      -- Create the autocmd outside of on_attach to ensure it's always available
      vim.api.nvim_create_autocmd({ "CursorMoved" }, {
        pattern = "*",
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          if git_blame_enabled[bufnr] then
            show_git_blame()
          end
        end,
      })

      -- Setup gitsigns
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = false,
        on_attach = function(bufnr)
          -- Gitsigns-specific functionality can be added here
          -- The git blame toggle is now global and not tied to on_attach
        end,
      })
    end,
  }
}

