return {
  -- Enhanced UI for vim.ui.* functions
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      -- Check if telescope is available
      local has_telescope, telescope = pcall(require, "telescope")
      local telescope_theme = {}
      
      if has_telescope then
        telescope_theme = require("telescope.themes").get_dropdown({
          layout_config = {
            width = 0.65,
            height = 0.7,
          },
          borderchars = {
            prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
            results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
            preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          },
        })
      end
      
      require("dressing").setup({
        input = {
          -- Set to false if you don't like the input window
          enabled = true,
          default_prompt = "Input:",
          title_pos = "center",
          insert_only = true,
          start_in_insert = true,
          border = "rounded",
          -- Avoid excessively wide input window
          relative = "cursor",
          prefer_width = 30,
          width = nil,
          max_width = { 140, 0.9 },
          min_width = { 20, 0.2 },
          -- Add padding inside the input window
          win_options = {
            winblend = 0,
            winhighlight = "NormalFloat:DiagnosticOk",
          },
          -- Add mapping to move in input field
          mappings = {
            n = {
              ["<Esc>"] = "Close",
              ["<CR>"] = "Confirm",
            },
            i = {
              ["<C-c>"] = "Close",
              ["<CR>"] = "Confirm",
              ["<Up>"] = "HistoryPrev",
              ["<Down>"] = "HistoryNext",
            },
          },
        },
        select = {
          -- An enhanced vim.ui.select with nice UI
          enabled = true,
          backend = has_telescope and { "telescope", "builtin" } or { "builtin" },
          trim_prompt = true,
          -- Display formatting icons
          format_item_override = {},
          -- Telescope options (only if available)
          telescope = has_telescope and telescope_theme or nil,
          -- Built-in window options - important for theme preview
          builtin = {
            border = "rounded",
            relative = "editor",
            win_options = {
              winblend = 0,
              winhighlight = "CursorLine:PmenuSel",
            },
            width = nil,
            max_width = { 140, 0.8 },
            min_width = { 40, 0.3 },
            height = nil,
            max_height = 0.6,
            min_height = { 10, 0.2 },
            -- Add mappings for the selection window
            mappings = {
              ["<Esc>"] = "Close",
              ["<C-c>"] = "Close",
              ["<CR>"] = "Confirm",
              ["<Up>"] = function() 
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, false, true), "n", false)
                -- Allow time for the on_preview hook to run
                vim.defer_fn(function() vim.cmd("redraw") end, 50)
              end,
              ["<Down>"] = function()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, false, true), "n", false)
                -- Allow time for the on_preview hook to run
                vim.defer_fn(function() vim.cmd("redraw") end, 50)
              end,
              ["<C-p>"] = "Move(-1)",
              ["<C-n>"] = "Move(1)",
              ["<C-u>"] = "Move(-5)",
              ["<C-d>"] = "Move(5)",
              ["<PageUp>"] = "Move(-10)",
              ["<PageDown>"] = "Move(10)",
              ["<C-j>"] = function()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, false, true), "n", false)
                vim.defer_fn(function() vim.cmd("redraw") end, 50)
              end,
              ["<C-k>"] = function()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, false, true), "n", false)
                vim.defer_fn(function() vim.cmd("redraw") end, 50)
              end,
            },
            -- Features for previewing the selection
            preview = {
              enabled = true,
              event_trigger = "CursorMoved", -- Important for theme preview
              preview_delay = 50, -- Small delay for performance
              preview_hl_group = "Search",
            }
          }
        }
      })
    end
  }
} 