return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- optional, for file icons
  },
  version = "*", -- Use latest release
  lazy = false,  -- Load at startup
  priority = 1000, -- Highest priority to ensure it loads first
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle File Explorer" },
    { "<leader>fe", "<cmd>NvimTreeFocus<CR>", desc = "Focus File Explorer" },
    { "<C-b>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree (VSCode style)" },
  },
  config = function()
    -- Setup with recommended options
    require("nvim-tree").setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
      },
      filters = {
        dotfiles = false,
        custom = { "^.git$" },
      },
      git = {
        enable = true,
        ignore = false,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          window_picker = {
            enable = true,
          },
        },
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        
        -- Apply default mappings
        api.config.mappings.default_on_attach(bufnr)
        
        -- Add VSCode-like mappings
        vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
        vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
      end,
    })
    
    -- Simple handler for directory opening
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        -- Only handle when a directory is passed
        local is_directory = vim.fn.isdirectory(data.file) == 1
        
        if is_directory then
          -- Change to the directory
          vim.cmd.cd(data.file)
          -- Open the tree
          require("nvim-tree.api").tree.open()
        end
      end,
      nested = true,
    })
  end,
} 