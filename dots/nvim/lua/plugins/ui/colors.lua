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
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        filetypes = {
          "*", -- Apply to all file types
          css = { names = true }, -- Highlight named colors in CSS
          conf = { names = true }, -- Enable in config files
          json = { names = true }, -- Enable in JSON files
        },
        user_default_options = {
          mode = "background", -- Set the display mode
          tailwind = false,    -- Enable tailwind colors
          css = true,          -- Enable CSS features
          css_fn = true,       -- Parse CSS functions
          rgb_fn = true,       -- Parse rgb() func
          names = false,       -- "Name" codes like Blue
          virtualtext = "■",   -- Show virtual text
        },
      })
    end,
  },

  -- Markdown renderer
  {
    'MeanderingProgrammer/render-markdown.nvim',
  },

  -- Image clipboard plugin
  {
    "HakonHarnes/img-clip.nvim",
  },
}
