return {
  -- Primary theme - Monokai Pro
  {
    "tanvirtin/monokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("monokai").setup({
        palette = require("monokai").pro
      })
      vim.cmd.colorscheme("monokai_pro")
    end,
  },
  
  -- Additional themes - all lazy loaded
  
  -- TokyoNight
  {
    "folke/tokyonight.nvim",
    lazy = true,
    config = function()
      require("tokyonight").setup({
        style = "storm",
      })
    end,
  },
  
  -- NightFox Collection
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    config = function()
      require("nightfox").setup({})
    end,
  },
  
  -- OneDark
  {
    "navarasu/onedark.nvim",
    lazy = true,
    config = function()
      require("onedark").setup({
        style = "darker",
      })
    end,
  },
  
  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        integrations = {
          treesitter = true,
          telescope = true,
          cmp = true,
        },
      })
    end,
  },
  
  -- Gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
        italic = {
          strings = false,
          comments = true,
          operators = false,
          folds = true,
        },
      })
    end,
  },
  
  -- Dracula
  {
    "Mofiqul/dracula.nvim",
    lazy = true,
  },
  
  -- Solarized
  {
    "maxmx03/solarized.nvim",
    lazy = true,
    config = function()
      require("solarized").setup({
        theme = 'neo',
      })
    end,
  },
  
  -- Base16
  {
    "RRethy/nvim-base16",
    lazy = true,
  },
  
  -- Material
  {
    "marko-cerovac/material.nvim",
    lazy = true,
    config = function()
      require("material").setup({
        styles = { 
          comments = { italic = true },
        },
      })
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
