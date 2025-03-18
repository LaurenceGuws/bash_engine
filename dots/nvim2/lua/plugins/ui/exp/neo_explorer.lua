return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- already a dependency of nvim-tree
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  lazy = false,  -- Load at startup
  priority = 900, -- High priority but below theme (1000)
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle File Explorer" },
    { "<leader>fe", "<cmd>Neotree reveal<CR>", desc = "Focus File Explorer on Current File" },
    { "<C-b>", "<cmd>Neotree toggle<CR>", desc = "Toggle File Explorer (VSCode style)" },
    -- Add useful additional commands
    { "<leader>be", "<cmd>Neotree float buffers<CR>", desc = "Buffer Explorer (Float)" },
    { "<leader>ge", "<cmd>Neotree float git_status<CR>", desc = "Git Explorer (Float)" },
    -- Easy switch between sources with numeric keybindings
    { "<leader>e1", "<cmd>Neotree focus filesystem<CR>", desc = "Explorer: Files View" },
    { "<leader>e2", "<cmd>Neotree focus buffers<CR>", desc = "Explorer: Buffers View" },
    { "<leader>e3", "<cmd>Neotree focus git_status<CR>", desc = "Explorer: Git View" },
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = false,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      sources = {
        "filesystem",
        "buffers",
        "git_status",
      },
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
      window = {
        width = 30,
        mappings = {
          ["<space>"] = false,
          ["<cr>"] = "open",
          ["l"] = "open",
          ["h"] = "close_node",
          ["v"] = "open_vsplit",
          ["s"] = "open_split",
          ["c"] = "copy", 
          ["m"] = "move",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["q"] = "close_window",
        }
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "󰜌",
          default = "",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
        },
        git_status = {
          symbols = {
            added = "✚",
            modified = "",
            deleted = "✖",
            renamed = "󰁕",
            untracked = "?",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          }
        },
      },
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            -- Auto close if screen is small
            if vim.fn.winwidth(0) < 100 then
              vim.cmd("Neotree close")
            end
          end
        },
      },
    })
    
    -- Basic highlighting for Neo-tree elements
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "neo-tree",
      callback = function()
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = "#b4befe", bold = true })
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#cba6f7" })
        vim.api.nvim_set_hl(0, "NeoTreeFileIcon", { fg = "#a6e3a1" })
        vim.api.nvim_set_hl(0, "NeoTreeFileName", { fg = "#cdd6f4" })
        vim.api.nvim_set_hl(0, "NeoTreeIndentMarker", { fg = "#6c7086" })
        
        -- Simple window settings
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
      end
    })

    -- Handle directory opening
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        local is_directory = vim.fn.isdirectory(data.file) == 1
        if is_directory then
          vim.cmd.cd(data.file)
          vim.cmd("Neotree")
        end
      end,
      nested = true,
    })
  end,
} 
