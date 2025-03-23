-- Configure web icons
return {
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
}
