return {
  -- Catppuccin Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- Options: latte, frappe, macchiato, mocha
        transparent_background = true,
        integrations = {
          treesitter = true,
          telescope = true,
          bufferline = true,
          cmp = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Colorizer for Highlighting Color Codes
  {
    "NvChad/nvim-colorizer.lua",
    'MeanderingProgrammer/render-markdown.nvim',
    "HakonHarnes/img-clip.nvim",
    config = function()
      require("colorizer").setup({
        "*", -- Apply to all file types
        css = { names = true; }, -- Highlight named colors in CSS
        conf = { names = true; }, -- Enable in config files
        json = { names = true; }, -- Enable in config files

      })
    end,
  }
}
