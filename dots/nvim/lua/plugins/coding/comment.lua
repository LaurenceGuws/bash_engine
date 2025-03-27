return {
	"numToStr/Comment.nvim",
	event = "VeryLazy",
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		require("Comment").setup({
			-- Configure with explicit mappings to avoid overlap
			mappings = {
				-- Disable default mappings completely to avoid redundancy
				-- with the custom ones defined in keymaps.lua
				basic = false,
				extra = false,
			},
			-- Pre-hook to determine the commenting style to use
			pre_hook = function(ctx)
				local U = require("Comment.utils")

				-- Determine whether to use linewise or blockwise commentstring
				local type = ctx.ctype == U.ctype.linewise and "__default" or "__multiline"

				-- Determine the location where to calculate commentstring from
				local location = nil
				if ctx.ctype == U.ctype.blockwise then
					location = require("ts_context_commentstring.utils").get_cursor_location()
				elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
					location = require("ts_context_commentstring.utils").get_visual_start_location()
				end

				return require("ts_context_commentstring.internal").calculate_commentstring({
					key = type,
					location = location,
				})
			end,
		})

		-- IMPORTANT: All comment keymaps are defined in lua/core/keymaps.lua using:
		-- <C-/> and <C-_> for normal, visual, and insert mode
	end,
}
