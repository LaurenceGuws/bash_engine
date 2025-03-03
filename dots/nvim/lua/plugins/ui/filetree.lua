return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- optional, for file icons
  },
  version = "*", -- Use latest release
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle File Explorer" },
    { "<leader>fe", "<cmd>NvimTreeFocus<CR>", desc = "Focus File Explorer" },
  },
  config = function()
    local function on_attach(bufnr)
      local api = require("nvim-tree.api")
      
      -- VSCode-like keybindings
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
      
      -- Set keymaps for navigating and manipulating files
      vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "<C-e>", api.node.open.replace_tree_buffer, opts("Open: In Place"))
      vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Open: Vertical Split"))
      vim.keymap.set("n", "<C-s>", api.node.open.horizontal, opts("Open: Horizontal Split"))
      vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
      vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
      vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
      vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("Preview"))
      vim.keymap.set("n", "<C-k>", api.node.navigate.sibling.prev, opts("Previous Sibling"))
      vim.keymap.set("n", "<C-j>", api.node.navigate.sibling.next, opts("Next Sibling"))
      vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
      vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
      vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
      vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
      vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
      
      -- File operations (like VSCode)
      vim.keymap.set("n", "a", api.fs.create, opts("Create"))
      vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
      vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
      vim.keymap.set("n", "<C-r>", api.fs.rename_sub, opts("Rename: Omit Filename"))
      vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
      vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
      vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
      vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
      vim.keymap.set("n", "<C-y>", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
      vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
      
      -- Folder operations
      vim.keymap.set("n", "e", api.tree.expand_all, opts("Expand All"))
      vim.keymap.set("n", "w", api.tree.collapse_all, opts("Collapse All"))
      vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
      vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse All"))
      
      -- Help and info
      vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
      vim.keymap.set("n", "i", api.node.show_info_popup, opts("Info"))
      vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
      
      -- Filtering
      vim.keymap.set("n", "f", api.live_filter.start, opts("Filter"))
      vim.keymap.set("n", "F", api.live_filter.clear, opts("Clean Filter"))
    end
      
    require("nvim-tree").setup({
      on_attach = on_attach,
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
        adaptive_size = false,
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
        highlight_opened_files = "name",
        root_folder_label = ":~:s?$?/..?",
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
          modified_placement = "after",
          padding = " ",
          symlink_arrow = " ➛ ",
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
            modified = true,
          },
          glyphs = {
            default = "",
            symlink = "",
            bookmark = "󰆤",
            modified = "●",
            folder = {
              arrow_closed = "",
              arrow_open = "",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      },
      filters = {
        dotfiles = false,
        git_clean = false,
        no_buffer = false,
        custom = {},
        exclude = {},
      },
      update_focused_file = {
        enable = true,
        update_cwd = true,
        ignore_list = {},
      },
      git = {
        enable = true,
        ignore = false,
        timeout = 500,
      },
      actions = {
        use_system_clipboard = true,
        change_dir = {
          enable = true,
          global = false,
          restrict_above_cwd = false,
        },
        expand_all = {
          max_folder_discovery = 300,
          exclude = {},
        },
        file_popup = {
          open_win_config = {
            col = 1,
            row = 1,
            relative = "cursor",
            border = "rounded",
            style = "minimal",
          },
        },
        open_file = {
          quit_on_open = false,
          resize_window = true,
          window_picker = {
            enable = true,
            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            exclude = {
              filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
              buftype = { "nofile", "terminal", "help" },
            },
          },
        },
      },
      trash = {
        cmd = "gio trash", -- or "trash-put"
        require_confirm = true,
      },
      live_filter = {
        prefix = "[FILTER]: ",
        always_show_folders = true,
      },
      log = {
        enable = false,
        truncate = false,
        types = {
          all = false,
          config = false,
          copy_paste = false,
          diagnostics = false,
          git = false,
          profile = false,
        },
      },
    })
    
    -- Auto close if last window
    vim.api.nvim_create_autocmd("BufEnter", {
      nested = true,
      callback = function()
        if #vim.api.nvim_list_wins() == 1 and
           vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil and
           vim.bo.filetype == "NvimTree" then
          vim.cmd("quit")
        end
      end
    })
  end,
} 