-- Telescope configuration
return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	lazy = false, -- Important: Don't lazy load Telescope
	version = false,
	config = function()
		local telescope = require("telescope")

		-- Setup Telescope with minimal customization to keep the default UI
		telescope.setup({
			defaults = {
				prompt_prefix = " ",
				selection_caret = " ",
				path_display = { "smart" },
				sorting_strategy = "ascending",
				file_ignore_patterns = { "node_modules" },
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
						["<C-c>"] = "close",
					},
				},
			},
			pickers = {
				-- No customizations for pickers to keep default UI
				live_grep = {
					additional_args = function()
						return { "--hidden" }
					end,
				},
				colorscheme = {
					enable_preview = true,
				},
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
		})

		-- Load extensions if available
		pcall(telescope.load_extension, "fzf")
	end,
}
