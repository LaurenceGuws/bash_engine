-- Icons for Snacks and other UI elements
return {
	{
		"echasnovski/mini.nvim",
		lazy = false,
		priority = 9999,
		config = function()
			require("mini.icons").setup()
		end,
	},
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		config = function()
			require("nvim-web-devicons").setup({
				-- Override icon defaults
				override = {},
				-- Global options
				default = true,
				strict = true,
			})
		end,
	},
}
