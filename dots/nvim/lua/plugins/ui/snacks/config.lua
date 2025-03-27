-- Configuration options for snacks.nvim

return {
	bigfile = { enabled = true },
	dashboard = {
		enabled = true,
		pane_gap = 6,
		sections = {
			{ section = "header" },
			{
				section = "keys",
				title = "Files",
				icon = " ",
				gap = 1,
				padding = 1,
			},
			{
				pane = 2,
				section = "recent_files",
				icon = " ",
				title = "Recent Files",
				indent = 2,
				padding = 1,
				limit = 5,
			},
			{ section = "startup" },
		},
		preset = {
			header = [[
░█▀█░█▀▀░█▀█░█░█░▀█▀░█▄█
░█░█░█▀▀░█░█░▀▄▀░░█░░█░█
░▀░▀░▀▀▀░▀▀▀░░▀░░▀▀▀░▀░▀
]],
			keys = {
				{ icon = "󰏖 ", key = "m", desc = "Mason -> language support", action = ":Mason" },
				{ icon = " ", key = "L", desc = "Lazy -> nvim plugins", action = ":Lazy" },
				{ icon = " ", key = "H", desc = "Health -> check nvim", action = ":checkhealth" },
				{ icon = " ", key = "t", desc = "Telescope", action = ":Telescope" },
				{ icon = "󰘥 ", key = "h", desc = "Help", action = ":help" },
				{ icon = "󰩈 ", key = "q", desc = "Quit -> close nvim", action = ":qa" },
			},
		},
	},
	explorer = { enabled = true, replace_netrw = false, hidden = true, auto_open = false },
	image = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true, override_ui = true },
	notifier = { enabled = false, timeout = 0, popups = false },
	picker = { enabled = true, override_ui = false },
	quickfile = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	terminal = {
		enabled = true,
		win = { style = "terminal", border = "rounded" },
		shell = vim.o.shell,
	},
	toggle = { enabled = true, notify = true, which_key = true },
	words = { enabled = true },
	styles = {
		notification = {},
		terminal = {
			bo = { filetype = "snacks_terminal" },
			wo = {},
			keys = {
				q = "hide",
				term_normal = {
					"<esc>",
					function(self)
						self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
						if self.esc_timer:is_active() then
							self.esc_timer:stop()
							vim.cmd("stopinsert")
						else
							self.esc_timer:start(200, 0, function() end)
							return "<esc>"
						end
					end,
					mode = "t",
					expr = true,
					desc = "Double escape to normal mode",
				},
			},
		},
	},
}
