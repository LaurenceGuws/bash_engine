-- Configuration options for snacks.nvim

return {
	bigfile = { enabled = false },
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
	indent = {
		priority = 1,
		enabled = false, -- enable indent guides
		char = "│",
		only_scope = true, -- only show indent guides of the scope
		only_current = true, -- only show indent guides in the current window
		-- hl = "SnacksIndent", ---@type string|string[] hl groups for indent guides
		-- can be a list of hl groups to cycle through
		hl = {
			"SnacksIndent1",
			"SnacksIndent2",
			"SnacksIndent3",
			"SnacksIndent4",
			"SnacksIndent5",
			"SnacksIndent6",
			"SnacksIndent7",
			"SnacksIndent8",
		},
	},
	-- animate scopes. Enabled by default for Neovim >= 0.10
	-- Works on older versions but has to trigger redraws during animation.
	---@class snacks.indent.animate: snacks.animate.Config
	---@field enabled? boolean
	--- * out: animate outwards from the cursor
	--- * up: animate upwards from the cursor
	--- * down: animate downwards from the cursor
	--- * up_down: animate up or down based on the cursor position
	---@field style? "out"|"up_down"|"down"|"up"
	animate = {
		enabled = vim.fn.has("nvim-0.10") == 1,
		style = "out",
		easing = "linear",
		duration = {
			step = 20, -- ms per step
			total = 500, -- maximum duration
		},
	},
	---@class snacks.indent.Scope.Config: snacks.scope.Config
	scope = {
		enabled = true, -- enable highlighting the current scope
		priority = 200,
		char = "│",
		underline = true, -- underline the start of the scope
		only_current = true, -- only show scope in the current window
		hl = "SnacksIndentScope", ---@type string|string[] hl group for scopes
	},
	chunk = {
		-- when enabled, scopes will be rendered as chunks, except for the
		-- top-level scope which will be rendered as a scope.
		enabled = true,
		-- only show chunk scopes in the current window
		only_current = true,
		priority = 200,
		hl = "SnacksIndentChunk", ---@type string|string[] hl group for chunk scopes
		char = {
			corner_top = "┌",
			corner_bottom = "└",
			-- corner_top = "╭",
			-- corner_bottom = "╰",
			horizontal = "─",
			vertical = "│",
			arrow = ">",
		},
	},
	input = { enabled = true, override_ui = true },
	notifier = { enabled = false },
	picker = { enabled = true },
	quickfile = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	terminal = {
		enabled = true,
		win = { style = "terminal", border = "rounded" },
		shell = vim.o.shell,
	},
	toggle = { enabled = true },
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
