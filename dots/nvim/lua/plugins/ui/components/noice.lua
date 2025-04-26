-- Noice UI improvements
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    -- OPTIONAL: 
    -- "rcarriga/nvim-notify",
  },
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup", -- Use popup for cmdline so it doesn't push lualine up
      opts = { 
        -- Position the cmdline popup at the top to avoid conflicts with lualine
        position = {
          row = 5,
          col = "50%",
        },
      },
    },
    messages = {
      -- Enable messages but route them to appropriate views
      enabled = true,
      view = "mini", -- Use mini view that doesn't push lualine up
      view_error = "mini",
      view_warn = "mini",
      view_history = "messages", -- Separate buffer for message history
      view_search = "virtualtext", -- Show search count as virtual text
    },
    -- No notifications popups
    notify = {
      enabled = true,
      view = "mini", -- Route notifications to mini view instead
    },
    -- Enable the message history command
    commands = {
      history = {
        view = "split",
        opts = { enter = true, format = "details" },
        filter = {
          any = {
            { error = true },
            { warning = true },
            { event = "msg_show", kind = { "" } },
            { event = "lsp", kind = "message" },
          },
        },
      },
    },
    -- Disable LSP features initially
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
        ["vim.lsp.util.stylize_markdown"] = false,
      },
      progress = {
        enabled = false, -- Disable the LSP progress messages
      },
    },
    presets = {
      bottom_search = false, -- Don't use bottom search as it would appear below lualine
      command_palette = true, -- Use command palette to position cmdline
      long_message_to_split = true, -- Long messages go to split
      lsp_doc_border = false,
    },
    -- Configure the popup menu
    popupmenu = {
      enabled = true, 
      backend = "nui", 
    },
    routes = {
      -- Skip showing those pesky search count messages
      {
        filter = { event = "msg_show", kind = "search_count" },
        opts = { skip = true },
      },
    },
    views = {
      mini = {
        position = {
          row = 1, 
          col = "100%",
        },
        border = {
          style = "none",
        },
        win_options = {
          winblend = 0, 
        },
      },
    },
  },
} 