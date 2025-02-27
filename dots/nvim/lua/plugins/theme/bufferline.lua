return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers", -- Show buffers, alternative: "tabs"
        numbers = "ordinal", -- Show buffer numbers
        close_command = "bdelete! %d", -- Close buffer with `X`
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = {
          icon = "▎", -- Indicator for active buffer
          style = "icon",
        },
        buffer_close_icon = "",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        diagnostics = "nvim_lsp", -- Show LSP diagnostics on buffers
        diagnostics_indicator = function(count, level, _, _)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        show_buffer_icons = true, -- Enable filetype icons
        show_buffer_close_icons = true,
        show_close_icon = false,
        persist_buffer_sort = true, -- Keep buffer order across sessions
        separator_style = "slant", -- Options: "slant", "padded_slant", "thick", "thin"
        enforce_regular_tabs = false,
        always_show_bufferline = true,
      },
    })
  end,
}
