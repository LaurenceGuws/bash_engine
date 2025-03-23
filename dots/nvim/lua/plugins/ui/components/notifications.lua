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

	-- Make the function available globally
	_G.show_notification_history = show_notification_history
	vim.api.nvim_create_user_command("NotificationLogToggle", show_notification_history, {})
end

return M
