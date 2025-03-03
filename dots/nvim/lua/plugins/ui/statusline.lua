return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" }, -- Add Catppuccin
  config = function()
    require("lualine").setup({
      options = {
        theme = "catppuccin",
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        icons_enabled = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end
}

