-- Custom notification system as a separate component
local M = {}

-- Setup notification system
function M.setup()
	-- Store notification history
	local notification_history = {}

	-- Completely replace vim.notify and prevent popup notifications
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
		-- Create a new buffer for notifications
		local bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
		
		-- Format notifications as plain text
		local lines = {"=== Notification History ===", ""}
		
		if #notification_history == 0 then
			table.insert(lines, "No notifications")
		else
			for i, notif in ipairs(notification_history) do
				local level_str = "INFO"
				if notif.level == vim.log.levels.ERROR then
					level_str = "ERROR"
				elseif notif.level == vim.log.levels.WARN then
					level_str = "WARN"
				elseif notif.level == vim.log.levels.DEBUG then
					level_str = "DEBUG"
				end

				-- Remove timestamp as requested
				table.insert(lines, string.format("[%s] %s", level_str, notif.msg))
			end
		end
		
		-- Add a footer with help text
		table.insert(lines, "")
		table.insert(lines, "Press q or <Esc> to close, use y to copy lines")
		
		-- Set buffer lines
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
		
		-- Calculate window dimensions (60% of screen width/height)
		local width = math.floor(vim.o.columns * 0.6)
		local height = math.floor(vim.o.lines * 0.6)
		
		-- Create a floating window
		local winnr = vim.api.nvim_open_win(bufnr, true, {
			relative = "editor",
			width = width,
			height = height,
			row = math.floor((vim.o.lines - height) / 2),
			col = math.floor((vim.o.columns - width) / 2),
			style = "minimal",
			border = "rounded",
			title = "Notification History",
			title_pos = "center",
		})
		
		-- Set window options
		vim.api.nvim_win_set_option(winnr, "wrap", true)
		vim.api.nvim_win_set_option(winnr, "cursorline", true)
		
		-- Set buffer keymaps for easy closing
		vim.api.nvim_buf_set_keymap(bufnr, "n", "q", ":close<CR>", { noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
		
		-- Set buffer as non-modifiable but allow yanking
		vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
		
		-- Add syntax highlighting for different message types
		vim.api.nvim_buf_set_option(bufnr, "filetype", "notification_history")
		
		-- Create syntax highlighting for notification messages
		vim.cmd([[
			syntax clear
			syntax match NotificationTitle /^=== Notification History ===/
			syntax match NotificationError /\[ERROR\]/
			syntax match NotificationWarn /\[WARN\]/
			syntax match NotificationInfo /\[INFO\]/
			syntax match NotificationDebug /\[DEBUG\]/
			syntax match NotificationFooter /^Press q or <Esc> to close.*/
			
			highlight NotificationTitle guifg=#61afef gui=bold
			highlight NotificationError guifg=#e06c75 gui=bold
			highlight NotificationWarn guifg=#e5c07b
			highlight NotificationInfo guifg=#98c379
			highlight NotificationDebug guifg=#56b6c2
			highlight NotificationFooter guifg=#5c6370 gui=italic
		]])
	end

	-- Make the function available globally
	_G.show_notification_history = show_notification_history
	vim.api.nvim_create_user_command("NotificationLogToggle", show_notification_history, {})
end

return M
