return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- for file icons
    "ibhagwan/fzf-lua", -- Add direct dependency for context menu
    "nvim-lua/plenary.nvim", -- required by fzf-lua
    "MunifTanjim/nui.nvim", -- UI components for menus
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

    -- Better icons but keep default background
    local icons = {
      default = "󰈙",
      symlink = "󰌹",
      git = {
        unstaged = "󰝶",  -- More elegant git indicators
        staged = "󰄬",
        unmerged = "󰙢",
        renamed = "󰁕",
        untracked = "󰋙",
        deleted = "󰮉",
        ignored = "󰟢",
      },
      folder = {
        arrow_closed = "",
        arrow_open = "",
        default = "󰉋",
        open = "󰝰",
        empty = "󰉖",
        empty_open = "󰷏",
        symlink = "󰉕",
        symlink_open = "󰉕",
      },
    }

    -- Import the context menu module
    local context_menu = require("plugins.ui.exp.menus.context_menu")

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
      
      -- Disable default popup menu and set up our custom context menu
      vim.keymap.set("n", "<RightMouse>", "<LeftMouse><cmd>lua _G.nvim_tree_context_menu()<CR>", opts("Context Menu"))
      vim.keymap.set("n", "<leader>cm", "<cmd>lua _G.nvim_tree_context_menu()<CR>", opts("Context Menu"))
      
      -- Add traditional 'm' key mapping for context menu (like ranger, vifm, etc.)
      vim.keymap.set("n", "m", "<cmd>lua _G.nvim_tree_context_menu()<CR>", opts("Context Menu"))
      
      -- Set mousemodel to extend for this buffer to prevent default popup menu
      vim.opt_local.mousemodel = "extend"
    end

    -- Setup with theme-integrated options but better visuals
    nvim_tree.setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,  
        adaptive_size = true,
        cursorline = true,
        side = "left",
        preserve_window_proportions = true,
        signcolumn = "yes",
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
            title = " Files ",
            title_pos = "center",
          },
        },
      },
      renderer = {
        add_trailing = true,
        group_empty = true,
        highlight_git = true,
        full_name = false,
        highlight_opened_files = "all",
        highlight_modified = "all",
        root_folder_label = ":~",
        indent_width = 2,
        indent_markers = {
          enable = true,
          inline_arrows = true,
          icons = {
            corner = "╰",
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
          glyphs = icons,
        },
        special_files = { 
          "Cargo.toml", "Makefile", "README.md", "readme.md", "LICENSE",
          "package.json", "init.lua", ".gitignore", "Dockerfile"
        },
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
        show_on_dirs = true,  -- Show git info on directories
        show_on_open_dirs = true,  -- Show on open dirs
        timeout = 400,
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
      update_focused_file = {
        enable = true,                 -- Enable focused file highlighting
        update_root = true,            -- Update root directory to follow file
        ignore_list = {},              -- Don't ignore any files
        update_cwd = false,            -- Don't update cwd
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = true,
        debounce_delay = 50,
        severity = {
          min = vim.diagnostic.severity.HINT,
          max = vim.diagnostic.severity.ERROR,
        },
        icons = {
          hint = "󰌵",
          info = "󰋼",
          warning = "󰀦",
          error = "󰅚",
        },
      },
      on_attach = my_on_attach,
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
    
    -- Make the context menu function globally available
    _G.nvim_tree_context_menu = context_menu.open_context_menu
    
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

    -- Just enhance colors WITHOUT changing background
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NvimTree",
      callback = function()
        -- Softer more modern colors
        vim.api.nvim_set_hl(0, "NvimTreeRootFolder", { fg = "#fab387", bold = true }) 
        -- Change folder colors from blue to a more muted lavender/purple
        vim.api.nvim_set_hl(0, "NvimTreeFolderName", { fg = "#b4befe", bold = true }) 
        vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = "#cba6f7", italic = true }) 
        vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName", { fg = "#a6adc8", italic = true }) 
        vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = "#f9e2af" }) 
        vim.api.nvim_set_hl(0, "NvimTreeGitNew", { fg = "#a6e3a1" }) 
        vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = "#f38ba8" }) 
        vim.api.nvim_set_hl(0, "NvimTreeGitIgnored", { fg = "#6c7086" }) 
        vim.api.nvim_set_hl(0, "NvimTreeExecFile", { fg = "#a6e3a1", italic = true }) 
        vim.api.nvim_set_hl(0, "NvimTreeSpecialFile", { fg = "#f2cdcd" }) 
        vim.api.nvim_set_hl(0, "NvimTreeSymlink", { fg = "#f5c2e7" }) 
        vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = "#6c7086" }) 
        
        -- Enhanced highlight for opened files and folders - softer style
        vim.api.nvim_set_hl(0, "NvimTreeOpenedFile", { fg = "#cba6f7", italic = true }) -- Remove bold for softer look
        vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = "#313244", blend = 10 }) -- Softer highlight with blend
        
        -- More subtle highlight for active file
        vim.api.nvim_set_hl(0, "NvimTreeFileOpened", { fg = "#f5c2e7", italic = true }) -- Remove bold and bg for cleaner look
        
        -- Add rounded borders to the nvim-tree window (if visible)
        local wins = vim.api.nvim_list_wins()
        for _, win in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "NvimTree" then
            vim.api.nvim_win_set_option(win, "winhighlight", "Normal:NormalFloat,NormalFloat:NormalFloat,FloatBorder:FloatBorder")
          end
        end
      end
    })

    -- Add window padding for a more modern look
    vim.api.nvim_create_autocmd("BufWinEnter", {
      pattern = "NvimTree_*",
      callback = function()
        vim.wo.signcolumn = "yes:1" -- Make the signcolumn thinner
        vim.opt_local.statusline = " " -- Empty statusline for NvimTree
      end,
    })
    
    -- Track the current buffer and highlight it in nvim-tree
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        -- Only update when nvim-tree is visible
        local tree_wins = {}
        for _, win in pairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.api.nvim_buf_get_option(buf, "filetype")
          if ft == "NvimTree" then 
            table.insert(tree_wins, win)
          end
        end
        
        if #tree_wins > 0 and vim.bo.filetype ~= "NvimTree" then
          -- Get current file path
          local current_file = vim.fn.expand("%:p")
          if current_file ~= "" then
            -- Force NvimTree to update and highlight the file
            local api = require("nvim-tree.api")
            api.tree.find_file(current_file)
          end
        end
      end,
      pattern = "*",
    })
  end,
} 