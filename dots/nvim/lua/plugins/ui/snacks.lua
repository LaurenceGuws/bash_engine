return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	enabled = true,
	opts = {
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true },
		indent = { enabled = true },
		input = {
			enabled = true,
			override_ui = true,
		},
		notifier = {
			enabled = false, -- Disable the notifier but in a way that can still be indexed
			timeout = 0,
			popups = false,
		},
		picker = {
			enabled = true,
			override_ui = true,
		},
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		styles = {
			notification = {
				-- wo = { wrap = true }
			},
		},
	},
	init = function()
		-- Don't prevent loading, just disable in config
		-- package.loaded["snacks.notifier"] = {}

		-- Store the original UI handlers
		local original_handlers = {
			select = vim.ui.select,
			input = vim.ui.input,
		}

		-- Setup notification system before anything else
		local notification_history = {}
		local orig_notify = vim.notify

		-- Completely replace vim.notify and prevent any popup notifications
		vim.notify = function(msg, level, opts)
			table.insert(notification_history, {
				msg = msg,
				level = level or vim.log.levels.INFO,
				timestamp = os.time(),
				opts = opts or {},
			})

			if #notification_history > 100 then
				table.remove(notification_history, 1)
			end

			-- Only echo to command line, never use popups
			if level == vim.log.levels.ERROR then
				vim.api.nvim_echo({ { "ERROR: " .. msg, "ErrorMsg" } }, true, {})
			elseif level == vim.log.levels.WARN then
				vim.api.nvim_echo({ { "WARN: " .. msg, "WarningMsg" } }, true, {})
			else
				vim.api.nvim_echo({ { msg } }, true, {})
			end

			-- Return a notification handle but don't use the original notify
			return 1
		end

		-- Function to display notification history
		local function show_notification_history()
			local items = {}
			for i, notif in ipairs(notification_history) do
				local level_str = "INFO"
				if notif.level == vim.log.levels.ERROR then
					level_str = "ERROR"
				elseif notif.level == vim.log.levels.WARN then
					level_str = "WARN"
				elseif notif.level == vim.log.levels.DEBUG then
					level_str = "DEBUG"
				end

				local time_str = os.date("%H:%M:%S", notif.timestamp)
				table.insert(items, string.format("[%s] [%s] %s", time_str, level_str, notif.msg))
			end

			if #items == 0 then
				table.insert(items, "No notifications")
			end

			vim.ui.select(items, {
				prompt = "Notification History",
			}, function() end)
		end

		_G.show_notification_history = show_notification_history
		vim.api.nvim_create_user_command("NotificationLogToggle", show_notification_history, {})

		-- Create an autocmd to restore original UI handlers on exit
		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				vim.ui.select = original_handlers.select
				vim.ui.input = original_handlers.input
			end,
		})

		-- Setup custom tabline function (moved from tabs.lua)
		local function tabline()
			local s = ""

			-- Get all buffers
			local buffers = vim.api.nvim_list_bufs()
			local visible_buffers = {}

			for _, buf in ipairs(buffers) do
				if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
					table.insert(visible_buffers, buf)
				end
			end

			-- No buffers? Show empty tabline
			if #visible_buffers == 0 then
				return s
			end

			-- Loop through all buffers
			for i, buf in ipairs(visible_buffers) do
				-- Get buffer properties
				local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
				if filename == "" then
					filename = "[No Name]"
				end

				-- Format buffer name
				local bufnr = vim.api.nvim_buf_get_number(buf)

				-- Build buffer text
				local text = ""

				-- Add buffer number and highlight
				local hl_group = "TabLine"
				if buf == vim.api.nvim_get_current_buf() then
					hl_group = "TabLineSel"
					text = text .. "%#TabLineSel#"
				else
					text = text .. "%#TabLine#"
				end

				-- Add buffer content with number
				text = text .. " " .. bufnr .. ":" .. filename .. " "

				-- Add modified indicator
				if vim.bo[buf].modified then
					text = text .. "%#TabLineModified#●%#" .. hl_group .. "# "
				end

				s = s .. text
			end

			-- Set highlight group based on current buffer
			s = s .. "%#TabLineFill#"

			-- Fill the rest of the tabline
			s = s .. "%="

			-- Add right-aligned buffer count
			s = s .. "%#TabLine# " .. #visible_buffers .. " buffers "

			return s
		end

		-- Expose the tabline function globally
		_G.custom_tabline = tabline

		-- Setup the tabline
		vim.opt.showtabline = 2
		vim.opt.tabline = "%!v:lua._G.custom_tabline()"

		-- Add keymaps for buffer navigation
		vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
		vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next Buffer" })
		vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
		vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })

		-- Create buffer delete command
		vim.api.nvim_create_user_command("Bdelete", function(opts)
			local bufnr = vim.fn.bufnr()
			if vim.fn.buflisted(bufnr) == 0 then
				return
			end

			-- Save buffer number for later
			local current_bufnr = bufnr

			-- If there's only one buffer, create a new one first
			if #vim.fn.getbufinfo({ buflisted = 1 }) <= 1 then
				vim.cmd("enew")
			end

			-- Go to previous buffer
			vim.cmd("bprevious")

			-- Delete the original buffer
			vim.cmd("bd! " .. current_bufnr)
		end, {})

		vim.keymap.set("n", "<leader>bc", "<cmd>Bdelete<CR>", { desc = "Close Buffer" })

		-- Register autocmd to refresh tabline when entering buffers
		vim.api.nvim_create_autocmd({ "BufEnter" }, {
			callback = function()
				vim.opt.tabline = "%!v:lua._G.custom_tabline()"
			end,
		})

		-- Add verification for critical components after setup - without causing "already setup" errors
		vim.defer_fn(function()
			-- Get snacks if it's loaded, but don't setup again
			local ok_snacks, snacks = pcall(require, "snacks")
			if not ok_snacks then
				return
			end

			-- Register UI handlers if picker is loaded
			local ok_picker, picker = pcall(require, "snacks.picker")
			if ok_picker then
				vim.ui.select = picker.select
			end

			local ok_input, input = pcall(require, "snacks.input")
			if ok_input then
				vim.ui.input = input
			end

			-- Check if statusline contains 'snacks'
			local ok_status, _ = pcall(require, "snacks.statusline")
			if ok_status and not vim.o.statusline:match("snacks") then
				-- Do not call snacks.setup again
				vim.notify("Statusline not containing snacks - please restart Neovim", vim.log.levels.WARN)
			end

			-- Make sure icons and markdown preview work, but don't call setup again
			local ok_icons, _ = pcall(require, "snacks.icons")
			local ok_markdown, _ = pcall(require, "snacks.markdown")
		end, 100) -- Short delay to ensure everything is initialized
	end,
	keys = {
		{
			"<leader>e",
			function()
				local ok, explorer = pcall(require, "snacks.explorer")
				if ok then
					explorer()
				else
					vim.notify("Failed to load snacks.explorer", vim.log.levels.ERROR)
				end
			end,
			desc = "File Explorer",
		},
		{
			"<leader>tn",
			function()
				_G.show_notification_history()
			end,
			desc = "Notification History",
		},
		{
			"<leader>z",
			function()
				local ok, zen = pcall(require, "snacks.zen")
				if ok then
					zen()
				else
					vim.notify("Failed to load snacks.zen", vim.log.levels.ERROR)
				end
			end,
			desc = "Toggle Zen Mode",
		},
		{
			"<leader>n",
			function()
				_G.show_notification_history()
			end,
			desc = "Notification History",
		},
	},
}
