-- Enhanced markdown experience
return {
	-- Markdown rendering
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("render-markdown").setup({
				latex = {
					enabled = false, -- Disable latex support since latex2text is not installed
				},
			})
		end,
	},

	-- Image clipboard plugin
	{
		"HakonHarnes/img-clip.nvim",
		event = "BufEnter *.md",
		opts = {
			default_dir_path = "images",
			dir_creation = {
				create_nested = true, -- Create nested directories
			},
		},
	},
}
