return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    
    -- Set up which-key with updated options
    wk.setup({
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
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
      -- Simplified window configuration to avoid unsupported properties
      win = {
        border = "rounded",
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "left",
      },
    })
    
    -- Register keymaps with proper grouping using new format
    wk.add({
      -- Top level groups
      { "<leader>c", group = "code" },
      { "<leader>b", group = "buffer" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>l", group = "lsp" },
      { "<leader>m", group = "markdown" },
      { "<leader>t", group = "toggle" },
      { "<leader>w", group = "windows" },
      
      -- Explorer
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Explorer Toggle" },
      { "<leader>fe", "<cmd>NvimTreeFocus<CR>", desc = "Focus Explorer" },
      
      -- Buffer operations
      { "<leader>bn", "<cmd>bnext<CR>", desc = "Next Buffer" },
      { "<leader>bp", "<cmd>bprevious<CR>", desc = "Previous Buffer" },
      { "<leader>bd", "<cmd>bdelete<CR>", desc = "Delete Buffer" },
      
      -- Find operations - reorganized to avoid overlaps
      -- Find files
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fh", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find Hidden Files" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
      
      -- Find in buffer
      { "<leader>fb", group = "buffer" },
      { "<leader>fbb", "<cmd>FzfLua buffers<CR>", desc = "Buffer List (FZF)" },
      { "<leader>fbu", "<cmd>Telescope buffers<cr>", desc = "Telescope Buffers" },
      { "<leader>fbc", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search Current Buffer" },
      
      -- Find with grep
      { "<leader>fg", group = "grep" },
      { "<leader>fgg", "<cmd>FzfLua live_grep<CR>", desc = "Live Grep (FZF)" },
      { "<leader>fgf", "<cmd>Telescope git_files<cr>", desc = "Find Git Files" },
      { "<leader>fgw", "<cmd>FzfLua grep_cword<CR>", desc = "Grep Current Word" },
      
      -- Toggle options
      { "<leader>tgb", desc = "Toggle Git Blame" },
      
      -- Markdown
      { "<leader>md", "<cmd>RenderMarkdownToggle<CR>", desc = "Toggle Markdown Rendering" },
      { "<leader>mr", "<cmd>RenderMarkdownToggle<CR>", desc = "Render Markdown" },
    })
    
    -- Register other keymaps (non-leader) with new format
    -- Comment plugin mappings
    wk.add({
      { "gcc", desc = "Comment line" },
      { "gcb", desc = "Comment block" },
      { "gc", desc = "Comment selection", mode = "v" },
    })
    
    -- Terminal keymaps
    wk.add({
      { "<C-t>", "<cmd>ToggleTerm<CR>", desc = "Toggle Terminal" },
    })
    
    -- Add Which-Key help shortcut
    wk.add({
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Show Keymaps" },
    })
  end,
} 