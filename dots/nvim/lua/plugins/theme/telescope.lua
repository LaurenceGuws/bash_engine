return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-fzf-native.nvim" },
  lazy = false,
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
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
        current_buffer_fuzzy_find = { theme = "ivy" }, -- Fancy in-buffer search
      },
    })

    -- Keymap for searching inside the current buffer with a fancy popup
    vim.keymap.set("n", "<leader>fbc", function()
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        previewer = false,
      }))
    end, { desc = "Fuzzy search in current buffer" })

  end,
}
