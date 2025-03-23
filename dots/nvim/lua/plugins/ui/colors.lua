return {
	-- Primary theme - Tokyo Night
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1001, -- Highest priority to ensure it loads last
		config = function()
			require("tokyonight").setup({
				style = "night", -- Choose between 'storm', 'moon', 'night', and 'day'
				transparent = false, -- Enable this for transparent background
				terminal_colors = true, -- Set terminal colors
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
					functions = {},
					variables = {},
					sidebars = "dark",
					floats = "dark",
				},
				sidebars = { "qf", "help", "terminal", "packer", "NvimTree", "Trouble" },
				day_brightness = 0.3, -- Adjust brightness for the day style
				hide_inactive_statusline = false,
				dim_inactive = false,
				lualine_bold = false,
			})

			-- Set Tokyo Night as the default theme
			vim.cmd("colorscheme tokyonight-night")

			-- Save it as the selected theme for theme_picker
			vim.g.selected_theme = "tokyonight:night"
		end,
	},

	-- Monokai Pro - available but not default
	{
		"tanvirtin/monokai.nvim",
		lazy = true, -- Change to lazy load
		config = function()
			require("monokai").setup({
				palette = require("monokai").pro,
			})
		end,
	},

	-- Additional themes - all lazy loaded

	-- Nightfox colorscheme
	{
		"EdenEast/nightfox.nvim",
		lazy = true,
	},

	-- Catppuccin colorscheme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
	},

	-- Ensure we have other themes available for the theme picker
	{
		"navarasu/onedark.nvim",
		lazy = true,
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = true,
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
	},
	{
		"NLKNguyen/papercolor-theme",
		lazy = true,
	},

	-- Dracula
	{
		"Mofiqul/dracula.nvim",
		lazy = true,
	},

	-- Solarized
	{
		"maxmx03/solarized.nvim",
		lazy = true,
		config = function()
			require("solarized").setup({
				theme = "neo",
			})
		end,
	},

	-- Base16
	{
		"RRethy/nvim-base16",
		lazy = true,
	},

	-- Material
	{
		"marko-cerovac/material.nvim",
		lazy = true,
		config = function()
			require("material").setup({
				styles = {
					comments = { italic = true },
				},
			})
		end,
	},

	-- Colorizer for Highlighting Color Codes
	{
		"NvChad/nvim-colorizer.lua",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("colorizer").setup({
				filetypes = {
					"*", -- Apply to all file types
					css = { names = true }, -- Highlight named colors in CSS
					conf = { names = true }, -- Enable in config files
					json = { names = true }, -- Enable in JSON files
				},
				user_default_options = {
					mode = "background", -- Set the display mode
					tailwind = false, -- Enable tailwind colors
					css = true, -- Enable CSS features
					css_fn = true, -- Parse CSS functions
					rgb_fn = true, -- Parse rgb() func
					names = false, -- "Name" codes like Blue
					virtualtext = "■", -- Show virtual text
				},
			})
		end,
	},

	-- Markdown renderer
	{
		"MeanderingProgrammer/render-markdown.nvim",
	},

	-- Image clipboard plugin
	{
		"HakonHarnes/img-clip.nvim",
	},
}
