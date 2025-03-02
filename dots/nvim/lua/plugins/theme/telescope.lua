return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-fzf-native.nvim" },
  lazy = false,
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")

    -- Telescope Setup
    telescope.setup({
      defaults = {
        prompt_prefix = "🔍 ",
        selection_caret = "➜ ",
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
        mappings = {
          i = {
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-x>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-t>"] = actions.select_tab,
            ["<esc>"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = { theme = "dropdown" },
        live_grep = { theme = "dropdown" },
        buffers = { theme = "dropdown" },
        help_tags = { theme = "dropdown" },
      },
    })

    -- Keymaps
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true, desc = "Telescope Search" }

    -- Custom: Search occurrences in the current buffer
    keymap("n", "<leader>fbc", function()
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        previewer = false,
        prompt_title = "Find in Current Buffer",
      }))
    end, { desc = "Search occurrences in current buffer" })

  end,
}
