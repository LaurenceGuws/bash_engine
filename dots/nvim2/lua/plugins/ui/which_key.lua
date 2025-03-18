-- Which-key configuration using the v3 API
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- General options
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
      -- Use devicons if available
      mappings = true, -- Enable/disable icons for mappings
    },
    popup = {
      border = "rounded",
      position = "bottom",
      margin = { 1, 0, 1, 0 },
      padding = { 2, 2, 2, 2 },
      win_opts = { 
        winblend = 0,
        cursorline = true,
        cursorcolumn = false,
        winhighlight = {
          Normal = "WhichKeyNormal",
          FloatBorder = "WhichKeyBorder",
          Title = "WhichKeyTitle",
        },
      },
    },
    layout = {
      height = { min = 4, max = 25 },
      width = { min = 20, max = 50 },
      spacing = 3,
      align = "left",
    },
    -- Set up triggers properly (table format)
    triggers = { 
      { "<leader>", mode = { "n", "v" } },
      { "g", mode = { "n", "v" } },
      { "z", mode = "n" },
      { "<C-w>", mode = "n" },
      { "<auto>", mode = "nixsotc" },
    },
    -- Delay settings
    delay = 0, -- no delay for leader key
    -- Enable all the default plugins
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    -- Set up colorscheme integration
    colors = {
      -- Set to false to disable colors
      enable = true,
    },
    -- Define groups directly in opts (newer method)
    defaults = {
      mode = "n",
      ["<leader>f"] = { name = "+Find/Files" },
      ["<leader>fb"] = { name = "+Buffers" },
      ["<leader>fg"] = { name = "+Grep/Git" },
      ["<leader>t"] = { name = "+Terminal/Toggle" },
      ["<leader>td"] = { name = "+Diagnostics" },
      ["<leader>tb"] = { name = "+Terminal/System" },
      ["<leader>tg"] = { name = "+Terminal/Git/Games" },
      ["<leader>t1"] = { name = "+Terminal/Tools" },
      ["<leader>ta"] = { name = "+ANSI/Terminal" },
      ["<leader>d"] = { name = "+Database" },
      ["<leader>c"] = { name = "+Code" },
      ["<leader>g"] = { name = "+Git" },
      ["<leader>b"] = { name = "+Buffers", expand = function() 
          return require("which-key.extras").expand.buf()
        end 
      },
      ["<leader>m"] = { name = "+Markdown" },
      ["<leader>w"] = { proxy = "<c-w>", name = "+Windows" },
    },
    -- Sort options
    sort = {
      enable = true,
      order = "desc", -- descending alphabetical order
    },
    -- Window settings (using win instead of deprecated window)
    win = {
      -- Window configuration (no winblend here)
    },
  },
  config = function(_, opts)
    -- Initialize which-key with the options
    local which_key = require("which-key")
    which_key.setup(opts)
    
    -- Add shortcuts for buffer-local keymaps and hydra mode
    vim.keymap.set("n", "<leader>?", function()
      require("which-key").show({ global = false })
    end, { desc = "Buffer Local Keymaps (which-key)" })

    -- Add hydra mode for window management
    vim.keymap.set("n", "<leader>W", function()
      require("which-key").show({
        keys = "<c-w>",
        loop = true, -- keeps popup open until <esc>
      })
    end, { desc = "Window Commands (Hydra)" })
  end,
} 