return {
  "akinsho/bufferline.nvim",
  version = "*",
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
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        show_buffer_icons = true, -- Enable filetype icons
        show_buffer_close_icons = true,
        show_close_icon = false,
        persist_buffer_sort = true, -- Keep buffer order across sessions
        separator_style = "slant", -- Changed from "slant" to "thick" for better transparency support
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = {'close'}
        },
        offsets = {
          {
            filetype = "NvimTree", 
            text = "File Explorer",
            highlight = "Directory",
            separator = true
          }
        },
        highlights = {
          fill = {
            bg = {
              attribute = "bg",
              highlight = "Normal"
            }
          },
          background = {
            bg = {
              attribute = "bg",
              highlight = "TabLine"
            }
          },
          tab = {
            bg = {
              attribute = "bg",
              highlight = "TabLine"
            }
          },
          tab_selected = {
            bg = {
              attribute = "bg",
              highlight = "Normal"
            }
          },
          buffer_visible = {
            bg = {
              attribute = "bg",
              highlight = "TabLine"
            }
          },
          buffer_selected = {
            bg = {
              attribute = "bg",
              highlight = "Normal"
            },
            bold = true,
            italic = true,
          },
        },
      },
    })
  end,
}
