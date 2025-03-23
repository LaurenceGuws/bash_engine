return {
	-- Enhanced UI for vim.ui.* functions - Used by theme picker
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			-- Check if telescope is available
			local has_telescope, telescope = pcall(require, "telescope")
			local telescope_theme = {}

			if has_telescope then
				telescope_theme = require("telescope.themes").get_dropdown({
					layout_config = {
						width = 0.65,
						height = 0.7,
					},
					borderchars = {
						prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
						results = { "─", "│", " ", "│", "├", "┤", "┘", "└" },
						preview = { "─", "│", " ", "│", "┌", "┐", "┘", "└" },
					},
				})
			end

			require("dressing").setup({
				input = {
					enabled = true,
					default_prompt = "Input:",
					prompt_align = "left",
					insert_only = true,
					start_in_insert = true,
					border = "rounded",
					relative = "cursor",
					prefer_width = 40,
					width = nil,
					max_width = { 140, 0.9 },
					min_width = { 20, 0.2 },
					win_options = {
						winblend = 0,
						winhighlight = "Normal:Normal,NormalNC:Normal",
					},
					mappings = {
						n = {
							["<Esc>"] = "Close",
							["<CR>"] = "Confirm",
						},
						i = {
							["<C-c>"] = "Close",
							["<CR>"] = "Confirm",
							["<Up>"] = "HistoryPrev",
							["<Down>"] = "HistoryNext",
						},
					},
				},
				select = {
					enabled = true,
					backend = { "telescope", "fzf", "builtin" },
					trim_prompt = true,
					telescope = telescope_theme,
					builtin = {
						border = "rounded",
						relative = "editor",
						win_options = {
							winblend = 0,
							winhighlight = "Normal:Normal,NormalNC:Normal",
						},
						width = nil,
						max_width = { 140, 0.8 },
						min_width = { 40, 0.2 },
						height = nil,
						max_height = 0.9,
						min_height = { 10, 0.2 },
						mappings = {
							["<Esc>"] = "Close",
							["<C-c>"] = "Close",
							["<CR>"] = "Confirm",
						},
					},
				},
			})
		end,
	},
}
