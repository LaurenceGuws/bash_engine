return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "catppuccin/nvim",
  },
  config = function()
    -- Add error handling for theme loading
    local theme = "auto"
    local catppuccin_ok, _ = pcall(require, "catppuccin")
    if catppuccin_ok then
      -- Try to use catppuccin theme, fallback to auto if not found
      theme = "catppuccin"
    end

    require("lualine").setup({
      options = {
        theme = "catppuccin",
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        icons_enabled = true,
        globalstatus = true, -- Use a single statusline for all windows
        disabled_filetypes = {
          statusline = { "NvimTree", "dashboard" }, -- Don't show statusline in these filetypes
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { 
          {
            "filename",
            path = 1, -- Show relative path
            file_status = true, -- Shows file status (readonly, modified)
          }
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      -- Add inactive_sections to control what's shown in inactive windows
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      -- Add tabline configuration if needed
      tabline = {},
      extensions = { "fugitive", "quickfix", "lazy" }, -- Add extensions support
    })
  end
}

