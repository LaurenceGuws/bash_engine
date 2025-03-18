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

      -- Track state for gitsigns toggleable features
      local gitlens_features = {
        current_line_blame = false,
        word_diff = false,
        linehl = false,
        numhl = false,
      }

      -- Track git detective mode state
      local git_detective_mode = false

      -- Function to update gitsigns configuration
      local function update_gitsigns_config()
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
          numhl = gitlens_features.numhl,
          linehl = gitlens_features.linehl,
          word_diff = gitlens_features.word_diff,
          watch_gitdir = {
            interval = 1000,
            follow_files = true,
          },
          attach_to_untracked = true,
          current_line_blame = gitlens_features.current_line_blame,
          current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol',
            delay = 300,
            ignore_whitespace = false,
            virt_text_priority = 100,
          },
          on_attach = function(bufnr)
            -- Gitsigns-specific functionality can be added here
            -- The git blame toggle is now global and not tied to on_attach
          end,
        })
      end

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

      -- GitLens-like feature toggles
      vim.keymap.set("n", "<leader>tgc", function()
        gitlens_features.current_line_blame = not gitlens_features.current_line_blame
        update_gitsigns_config()
        if gitlens_features.current_line_blame then
          vim.notify("Git Current Line Blame Enabled", vim.log.levels.INFO)
        else
          vim.notify("Git Current Line Blame Disabled", vim.log.levels.WARN)
        end
      end, { desc = "Toggle Git Current Line Blame" })

      vim.keymap.set("n", "<leader>tgw", function()
        gitlens_features.word_diff = not gitlens_features.word_diff
        update_gitsigns_config()
        if gitlens_features.word_diff then
          vim.notify("Git Word Diff Enabled", vim.log.levels.INFO)
        else
          vim.notify("Git Word Diff Disabled", vim.log.levels.WARN)
        end
      end, { desc = "Toggle Git Word Diff" })

      vim.keymap.set("n", "<leader>tgl", function()
        gitlens_features.linehl = not gitlens_features.linehl
        update_gitsigns_config()
        if gitlens_features.linehl then
          vim.notify("Git Line Highlight Enabled", vim.log.levels.INFO)
        else
          vim.notify("Git Line Highlight Disabled", vim.log.levels.WARN)
        end
      end, { desc = "Toggle Git Line Highlight" })

      vim.keymap.set("n", "<leader>tgn", function()
        gitlens_features.numhl = not gitlens_features.numhl
        update_gitsigns_config()
        if gitlens_features.numhl then
          vim.notify("Git Number Highlight Enabled", vim.log.levels.INFO)
        else
          vim.notify("Git Number Highlight Disabled", vim.log.levels.WARN)
        end
      end, { desc = "Toggle Git Number Highlight" })

      -- Git Detective Mode toggle (enables/disables all git features)
      vim.keymap.set("n", "<leader>tgd", function()
        -- Toggle detective mode state
        git_detective_mode = not git_detective_mode
        
        -- Update all git feature states based on detective mode
        local bufnr = vim.api.nvim_get_current_buf()
        git_blame_enabled[bufnr] = git_detective_mode
        gitlens_features.current_line_blame = git_detective_mode
        gitlens_features.word_diff = git_detective_mode
        gitlens_features.linehl = git_detective_mode
        gitlens_features.numhl = git_detective_mode
        
        -- Apply changes
        update_gitsigns_config()
        
        -- Show or clear git blame information
        if git_detective_mode then
          show_git_blame()
          vim.notify("🕵️ Git Detective Mode Activated 🕵️", vim.log.levels.INFO)
        else
          vim.schedule(function()
            vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
          end)
          vim.notify("Git Detective Mode Deactivated", vim.log.levels.WARN)
        end
      end, { desc = "Toggle Git Detective Mode (All Features)" })

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

      -- Initialize gitsigns with default settings
      update_gitsigns_config()
    end,
  }
}

