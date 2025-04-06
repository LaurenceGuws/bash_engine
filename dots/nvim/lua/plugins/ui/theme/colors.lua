return {
	-- Primary theme - Tokyo Night
	{
		"folke/tokyonight.nvim",
		lazy = false, -- Keep this one eagerly loaded as it's the default
		priority = 1001, -- Highest priority to ensure it loads last
		config = function()
			-- Get path to persistence file
			local function get_persistence_path()
				local data_path = vim.fn.stdpath("data")
				return data_path .. "/theme.lua"
			end

			-- Setup tokyonight
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

			-- Load theme in a non-blocking way, after UI has initialized
			vim.defer_fn(function()
				-- Set Tokyo Night as default first to avoid any flashing
				vim.cmd("colorscheme tokyonight-night")
				vim.g.selected_theme = "tokyonight-night"

				-- Try to load saved theme (in the background)
				vim.defer_fn(function()
					local theme_file = get_persistence_path()
					local ok, theme = pcall(loadfile, theme_file)
					if ok and theme then
						local theme_name = theme()
						pcall(vim.cmd, "colorscheme " .. theme_name)
						vim.g.selected_theme = theme_name
					end

					-- Setup ColorScheme event to save theme changes
					vim.api.nvim_create_autocmd("ColorScheme", {
						callback = function()
							local theme = vim.api.nvim_exec("colorscheme", true)
							vim.g.selected_theme = theme

							-- Save to file (async)
							vim.defer_fn(function()
								local file = io.open(get_persistence_path(), "w")
								if file then
									file:write("return '" .. theme .. "'")
									file:close()
								end
							end, 10) -- Small delay to not block
						end,
					})

					-- Create global function to load all color schemes
					_G.load_all_colorschemes = function()
						-- This function will be called when needed
					end
				end, 100) -- Delay theme loading slightly
			end, 10) -- Small delay for initial theme setup
		end,
	},
	-- Base16
	-- {
	-- 	"RRethy/nvim-base16",
	-- 	lazy = true,
	-- 	cmd = "Telescope colorscheme",
	-- },

	-- Monokai Pro - available but not default
	{
		"tanvirtin/monokai.nvim",
		lazy = true, -- Now lazy loaded
		cmd = "Telescope colorscheme", -- Load when telescope colorscheme is executed
		config = function()
			require("monokai").setup({
				palette = require("monokai").pro,
			})
		end,
	},

	-- Additional themes - all lazy loaded with event trigger

	-- Nightfox colorscheme
	{
		"EdenEast/nightfox.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Catppuccin colorscheme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Ensure we have other themes available for the theme picker
	{
		"navarasu/onedark.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},
	{
		"NLKNguyen/papercolor-theme",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Dracula
	{
		"Mofiqul/dracula.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Solarized
	{
		"maxmx03/solarized.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
		config = function()
			require("solarized").setup({
				theme = "neo",
			})
		end,
	},

	-- Material
	{
		"marko-cerovac/material.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
		config = function()
			require("material").setup({
				styles = {
					comments = { italic = true },
				},
			})
		end,
	},

	-- Nord Theme
	{
		"shaunsingh/nord.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Rose Pine
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Everforest
	{
		"sainnhe/everforest",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Sonokai
	{
		"sainnhe/sonokai",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Edge
	{
		"sainnhe/edge",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Ayu
	{
		"Shatur/neovim-ayu",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Oxocarbon
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- GitHub Theme
	{
		"projekt0n/github-nvim-theme",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Nightfly
	{
		"bluz71/vim-nightfly-colors",
		name = "nightfly",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Melange
	{
		"savq/melange-nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Poimandres
	{
		"olivercederborg/poimandres.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Moonfly
	{
		"bluz71/vim-moonfly-colors",
		name = "moonfly",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Vim-enfocado
	{
		"wuelnerdotexe/vim-enfocado",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Modus Themes
	{
		"miikanissi/modus-themes.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Doom One
	{
		"NTBBloodbath/doom-one.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Horizon
	{
		"lunarvim/horizon.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- OneDarkPro
	{
		"olimorris/onedarkpro.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- VSCode Theme
	{
		"Mofiqul/vscode.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Noctis
	{
		"kartikp10/noctis.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
		dependencies = {
			"rktjmp/lush.nvim",
		},
	},

	-- Zenburn
	{
		"phha/zenburn.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Embark
	{
		"embark-theme/vim",
		name = "embark",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Minimal
	{
		"Yazeed1s/minimal.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Zephyr
	{
		"glepnir/zephyr-nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Apprentice
	{
		"romainl/Apprentice",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Tender
	{
		"jacoborus/tender.vim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Jellybeans
	{
		"metalelf0/jellybeans-nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
		dependencies = { "rktjmp/lush.nvim" },
	},

	-- Nightfox variants (Duskfox, Nordfox, etc.)
	{
		"EdenEast/nightfox.nvim",
		name = "nightfox-extra",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Palenight
	{
		"drewtempelmeyer/palenight.vim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Iceberg
	{
		"cocopon/iceberg.vim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- OceanicNext
	{
		"mhartington/oceanic-next",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Hybrid
	{
		"w0ng/vim-hybrid",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Snow
	{
		"nightsense/snow",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- One Half
	{
		"sonph/onehalf",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Deep Space
	{
		"tyrannicaltoucan/vim-deep-space",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Sierra
	{
		"AlessandroYorba/Sierra",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Alduin
	{
		"AlessandroYorba/Alduin",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Srcery
	{
		"srcery-colors/srcery-vim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Vim-two-firewatch
	{
		"rakr/vim-two-firewatch",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Papercolor (comfortable light theme)
	{
		"NLKNguyen/papercolor-theme",
		name = "papercolor-extra",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Falcon
	{
		"fenetikm/falcon",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Carbonfox (special Nightfox variant)
	{
		"EdenEast/nightfox.nvim",
		name = "carbonfox",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Mellow
	{
		"kvrohit/mellow.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Adwaita
	{
		"Mofiqul/adwaita.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Neosolarized
	{
		"svrana/neosolarized.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
		dependencies = { "tjdevries/colorbuddy.nvim" },
	},

	-- Nordic
	{
		"AlexvZyl/nordic.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Kanagawa-dragon
	{
		"rebelot/kanagawa.nvim",
		name = "kanagawa-dragon",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Boo
	{
		"rockerBOO/boo-colorscheme-nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Fluormachine
	{
		"maxmx03/fluoromachine.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
	},

	-- Miasma
	{
		"xero/miasma.nvim",
		lazy = true,
		cmd = "Telescope colorscheme",
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

	-- NOTE: Markdown-related plugins have been moved to lua/plugins/coding/languages/markdown/markdown.lua
}
