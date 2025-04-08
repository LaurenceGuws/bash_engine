return {
	"nvimdev/lspsaga.nvim",
	after = "nvim-lspconfig",
	config = function()
		require("lspsaga").setup({
			lightbulb = { sign = false },
			ui = {
				code_action = "",
			},
		})
	end,
}
