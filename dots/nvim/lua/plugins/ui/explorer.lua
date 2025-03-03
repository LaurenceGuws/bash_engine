return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- for file icons
    "catppuccin/nvim", -- ensure theme integration
  },
  version = "*", -- Use latest release
  lazy = false,  -- Load at startup
  priority = 900, -- High priority but below theme (1000)
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle File Explorer" },
    { "<leader>fe", "<cmd>NvimTreeFocus<CR>", desc = "Focus File Explorer" },
    { "<C-b>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree (VSCode style)" },
  },
  config = function()
    -- Make sure nvim-tree loads properly with error handling
    local status_ok, nvim_tree = pcall(require, "nvim-tree")
    if not status_ok then
      vim.notify("nvim-tree not found!", vim.log.levels.WARN)
      return
    end

    -- Set up UI integration with colors
    local function my_on_attach(bufnr)
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
    end

    -- Setup with theme-integrated options
    nvim_tree.setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
        adaptive_size = true,
        signcolumn = "yes",
        cursorline = true,
        float = {
          enable = false,
          quit_on_focus_loss = true,
          open_win_config = {
            relative = "editor",
            border = "rounded",
            width = 30,
            height = 30,
            row = 1,
            col = 1,
          },
        },
      },
      renderer = {
        add_trailing = true,
        group_empty = true,
        highlight_git = true,
        full_name = false,
        highlight_opened_files = "all",
        root_folder_label = ":~:s?$?/..?",
        indent_width = 2,
        indent_markers = {
          enable = true,
          inline_arrows = true,
          icons = {
            corner = "└",
            edge = "│",
            item = "│",
            bottom = "─",
            none = " ",
          },
        },
        icons = {
          webdev_colors = true,
          git_placement = "before",
          padding = " ",
          symlink_arrow = " → ",
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
          glyphs = {
            symlink = "",
            bookmark = "󰆤",
            folder = {
              arrow_closed = "",
              arrow_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              ignored = "◌",
            },
          },
        },
        special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md", "LICENSE" },
        symlink_destination = true,
      },
      filters = {
        dotfiles = false,
        custom = { "^.git$" },
        exclude = {},
      },
      git = {
        enable = true,
        ignore = false,
        timeout = 500,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = true,
          window_picker = {
            enable = true,
            picker = "default",
            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            exclude = {
              filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
              buftype = { "nofile", "terminal", "help" },
            },
          },
        },
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        debounce_delay = 50,
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },
      on_attach = my_on_attach,
      -- Override colors to match catppuccin theme
      hijack_directories = {
        enable = true,
        auto_open = true,
      },
      system_open = {
        cmd = nil,
        args = {},
      },
      notify = {
        threshold = vim.log.levels.INFO,
      },
      ui = {
        confirm = {
          remove = true,
          trash = true,
        },
      },
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

    -- Ensure nvim-tree window has a different statusline (or none)
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "NvimTree_*",
      callback = function()
        vim.opt_local.statusline = " "  -- Empty statusline for NvimTree
      end,
    })
  end,
} 