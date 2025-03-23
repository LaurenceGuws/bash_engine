local M = {}

-- Get path to persistence file
local function get_persistence_path()
	local data_path = vim.fn.stdpath("data")
	return data_path .. "/theme.lua"
end

-- Load saved theme (called during startup)
function M.load_saved_theme()
	local file_path = get_persistence_path()
	local ok, theme = pcall(loadfile, file_path)
	if ok and theme then
		return theme()
	end
	return nil
end

-- Save theme selection to a file (called on ColorScheme event)
function M.save_theme_selection(theme)
	local file_path = get_persistence_path()
	local file = io.open(file_path, "w")
	if file then
		file:write("return '" .. theme .. "'")
		file:close()
	end
end

-- Setup persistence (call this after Neovim is fully loaded)
function M.setup()
	-- Add autocmd to save theme when it changes via any method
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			local theme = vim.api.nvim_exec("colorscheme", true)
			vim.g.selected_theme = theme
			M.save_theme_selection(theme)
		end,
	})
end

return M
