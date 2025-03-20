return {
  {
    "m00qek/baleia.nvim",
    version = "*",
    lazy = false,
    config = function()
      -- Initialize the baleia plugin
      local baleia = require("baleia").setup({
        -- Style customization options (optional)
        colors = {
          background = "NONE", -- Use transparent background to match any theme
        },
        line_starts_at = 1, -- Process from first line
        -- Control how aggressively to strip ANSI codes
        strip = {
          escape = true, -- Remove ESC character
          --[[ List of sequences to strip other than SGR and cursor movement
            Available options: 'alert', 'bright', 'dim', 'invisible', 'reverse', 'title'
          ]]
          except = {},
        },
      })

      -- Create a global state for ANSI colorization
      vim.g.ansi_colors_enabled = false
      
      -- Function to toggle ANSI colorization
      local function toggle_ansi_colors()
        vim.g.ansi_colors_enabled = not vim.g.ansi_colors_enabled
        
        if vim.g.ansi_colors_enabled then
          baleia.once(0) -- Apply colors to current buffer
          vim.notify("ANSI Colors Enabled", vim.log.levels.INFO)
        else
          -- Reload the buffer to remove colorization
          local current_buf = vim.api.nvim_get_current_buf()
          local current_pos = vim.api.nvim_win_get_cursor(0)
          vim.cmd("e!")
          vim.api.nvim_win_set_cursor(0, current_pos)
          vim.notify("ANSI Colors Disabled", vim.log.levels.WARN)
        end
      end

      -- Command to convert ANSI escape sequences to terminal colors
      vim.api.nvim_create_user_command("BaleiaColorize", function()
        baleia.once(0)
      end, {
        desc = "Colorize ANSI escape sequences in current buffer",
      })

      -- Register the toggle command
      vim.api.nvim_create_user_command("ToggleAnsiColors", function()
        toggle_ansi_colors()
      end, {
        desc = "Toggle ANSI color processing in current buffer",
      })

      -- Set up keybinding for the toggle
      vim.keymap.set("n", "<leader>ta", function()
        toggle_ansi_colors()
      end, { desc = "Toggle ANSI Colors" })

      -- Automatically colorize when viewing files with specific extensions
      vim.api.nvim_create_autocmd({ "BufReadPost" }, {
        pattern = { "*.log", "*.out" },
        callback = function()
          if vim.g.ansi_colors_enabled then
            vim.cmd("BaleiaColorize")
          end
        end,
      })

      -- Setup for using with a pager
      vim.api.nvim_create_autocmd({ "TermOpen" }, {
        pattern = "*",
        callback = function(ev)
          -- Store the terminal buffer number
          local term_bufnr = ev.buf
          
          -- Create an autocmd that triggers when this terminal buffer is no longer a terminal
          vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
            buffer = term_bufnr,
            callback = function()
              -- Check if the buffer content is coming from a pager
              if vim.bo[term_bufnr].buftype ~= "terminal" and vim.g.ansi_colors_enabled then
                -- Apply colorization
                baleia.once(term_bufnr)
              end
            end,
            once = true,
          })
        end,
      })

      -- Setup Neovim as a pager command with colorization
      -- Create the function that will be used in shell alias/function
      vim.api.nvim_create_user_command("SetupAsPager", function()
        -- Apply baleia colorization when used as a pager
        vim.g.ansi_colors_enabled = true
        baleia.once(0)
        -- Set some good options for pager usage
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.cursorline = true
        vim.opt_local.cursorcolumn = false
        -- Map 'q' to quit immediately
        vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
      end, { desc = "Setup buffer for pager use with ANSI colors" })
    end,
  }
} 