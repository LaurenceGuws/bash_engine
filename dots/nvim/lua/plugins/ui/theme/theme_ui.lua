-- Theme UI configuration with picker function
local theme_ui = {
	-- Return a proper plugin spec
	"folke/lazy.nvim", -- Just a placeholder
	name = "theme_ui",
	config = function()
		-- No special config needed
	end,
}

-- Theme picker function that can be required from keymaps
function theme_ui.open_theme_picker()
	-- Always use Telescope for consistency with other pickers
	local has_telescope, telescope = pcall(require, "telescope.builtin")
	if has_telescope then
		-- Uses the global dropdown theme configured in telescope_config.lua
		telescope.colorscheme()
	end
end

return theme_ui
