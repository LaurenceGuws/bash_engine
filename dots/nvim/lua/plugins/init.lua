return {
  require("plugins.ui.colors"),        -- Previously theme.catppuccin
  require("plugins.ui.which-key"),     -- Previously editor.which-key
  require("plugins.ui.bufferline"),    -- Previously theme.bufferline
  require("plugins.ui.statusline"),    -- Previously theme.bar
  require("plugins.integrations.kubectl"), -- Previously toolbox.kubectl
  require("plugins.ui.fuzzy"),         -- Previously editor.fuzzy
  require("plugins.integrations.dadbod"), -- Previously toolbox.dadbod
  require("plugins.coding.lsp.init"),  -- Previously toolbox.lsp.init
  require("plugins.coding.git"),       -- Previously toolbox.git
  require("plugins.integrations.ai.avante"), -- Previously toolbox.ai.avante
  require("plugins.coding.comment"),   -- Previously toolbox.comment
  require("plugins.ui.ui-components"), -- Previously ui.noice
  require("plugins.ui.notify"),
  require("plugins.ui.icons"),         -- Previously ui.mini-icons
  require("plugins.ui.explorer"),      -- Previously editor.explorer 
  
  -- Replace the require with the proper spec
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      -- Disable LaTeX support to avoid warnings
      latex = { enabled = false },
    },
  },
  
  -- New dependencies for enhanced LSP experience
  { "folke/neodev.nvim" },
  { "b0o/schemastore.nvim" },
  { "folke/trouble.nvim" },
  { "onsails/lspkind.nvim" },
  { "petertriho/cmp-git" },
  { "windwp/nvim-autopairs" },
  { "rafamadriz/friendly-snippets" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/cmp-calc" },
  { "hrsh7th/cmp-nvim-lua" },
  { "nvimtools/none-ls.nvim" },
  
  -- Missing dependencies
  { "rcarriga/nvim-notify" },    -- Notification manager for Noice
  { "echasnovski/mini.icons" },  -- Icons for LuaSnip
  { 
    "benfowler/telescope-luasnip.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim"
    }
  },
}

