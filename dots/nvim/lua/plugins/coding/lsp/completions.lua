return {
	"saghen/blink.cmp",
	version = not vim.g.lazyvim_blink_main and "*",
	build = vim.g.lazyvim_blink_main and "cargo build --release",
	opts = function()
		local icons = {
			Text = "󰉿",
			Method = "󰆧",
			Function = "󰊕",
			Constructor = "",
			Field = "󰜢",
			Variable = "󰀫",
			Class = "󰠱",
			Interface = "",
			Module = "",
			Property = "󰜸",
			Unit = "",
			Value = "󰎠",
			Enum = "",
			Keyword = "󰌋",
			Snippet = "",
			Color = "󰏘",
			File = "󰈙",
			Reference = "",
			Folder = "",
			EnumMember = "",
			Constant = "󰏿",
			Struct = "",
			Event = "",
			Operator = "󰆕",
			TypeParameter = "󰊄"
		}
		
		
		-- Basic config as recommended by blink.cmp documentation
		return {
			snippets = {
				expand = function(snippet, _)
					local has_luasnip, luasnip = pcall(require, "luasnip")
					if has_luasnip then
						return luasnip.lsp_expand(snippet.body)
					end
				end,
			},
			appearance = {
				kind_icons = icons,
			},
			completion = {
				documentation = {
					auto_show = true,
				},
				ghost_text = {
					enabled = true,
				},
			},
			sources = {
				-- Default sources (don't use compat field)
				default = { "lsp", "path", "snippets", "buffer" },
			},
			cmdline = {
				enabled = true,
			},
		}
	end,
	dependencies = {
		"rafamadriz/friendly-snippets",
		-- Add blink.compat to dependencies
		{
			"saghen/blink.compat",
			opts = {},
			version = not vim.g.lazyvim_blink_main and "*",
		},
		-- Original plugins needed for compat
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-calc",
		"kristijanhusak/vim-dadbod-completion",
		"hrsh7th/cmp-nvim-lua",
		"petertriho/cmp-git",
		-- Keep Luasnip for snippet support
		{
			"L3MON4D3/LuaSnip",
			build = "make install_jsregexp",
			dependencies = { "rafamadriz/friendly-snippets" },
		},
		-- For tailwind colors support
		{
			"roobert/tailwindcss-colorizer-cmp.nvim",
			config = function()
				require("tailwindcss-colorizer-cmp").setup({
					color_square_width = 2,
				})
			end,
		},
		-- Enhanced hover documentation
		{
			"lewis6991/hover.nvim",
			config = function()
				require("hover").setup({
					init = function()
						require("hover.providers.lsp")
					end,
					preview_window = false,
					title = true,
				})
			end,
		},
		"MunifTanjim/nui.nvim", -- UI components
		"nvim-treesitter/nvim-treesitter",
		"jghauser/follow-md-links.nvim",
		"windwp/nvim-autopairs", -- Auto-close brackets, etc.
	},
	event = "InsertEnter",
	config = function(_, opts)
		-- Load snippets
		local has_luasnip, luasnip = pcall(require, "luasnip")
		if has_luasnip then
			require("luasnip.loaders.from_vscode").lazy_load()
		end
		
		-- Set up blink.compat for nvim-cmp sources
		local has_compat, blink_compat = pcall(require, "blink.compat")
		if has_compat then
			blink_compat.setup({
				nvim_cmp = {
					enabled = true,
					sources = {
						buffer = { name = "buffer" },
						path = { name = "path" },
						calc = { name = "calc" },
						["vim-dadbod-completion"] = { name = "vim-dadbod-completion" },
						git = { name = "cmp_git" },
						cmdline = { name = "cmdline" },
						nvim_lua = { name = "nvim_lua" },
					}
				}
			})
		end
		
		-- Setup autopairs integration
		local autopairs = require("nvim-autopairs")
		autopairs.setup({
			check_ts = true,
			disable_filetype = { "TelescopePrompt" },
			fast_wrap = {
				map = "<M-e>",
				chars = { "{", "[", "(", '"', "'" },
				pattern = string.gsub(" [%'%\"%>%]%)%}%,] ", "%s+", ""),
				end_key = "$",
				keys = "qwertyuiopzxcvbnmasdfghjkl",
				check_comma = true,
				highlight = "Search",
				highlight_grey = "Comment",
			},
		})
		
		-- Configure blink.cmp with opts
		local blink_cmp = require("blink.cmp")
		
		-- Make sure the options object includes the necessary configurations
		if not opts.sources then
			opts.sources = {}
		end
		if not opts.sources.default then
			opts.sources.default = { "lsp", "path", "snippets", "buffer" }
		end
		
		blink_cmp.setup(opts)

		-- Add database support for specific filetypes
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "sql", "mysql", "plsql" },
			callback = function()
				blink_cmp.update_sources({
					enabled = { "vim-dadbod-completion", "buffer" },
				})
			end,
		})

		-- Git completion for commit messages
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "gitcommit", "NeogitCommitMessage" },
			callback = function()
				blink_cmp.update_sources({
					enabled = { "git", "buffer" },
				})
			end,
		})

		-- Set up standard LSP handlers with borders and enhanced markdown support
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = "rounded",
			max_width = 120,
			max_height = 30,
		})

		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
			border = "rounded",
			max_width = 120,
			max_height = 30,
		})
		
		-- Add additional hover key binding outside of LSP
		vim.keymap.set("n", "K", function()
			require("hover").hover()
		end)
        
		-- Add a custom command to show fuller documentation
		vim.api.nvim_create_user_command("ShowFullDocs", function()
			-- Get the word under cursor
			local word = vim.fn.expand("<cword>")
			-- Request hover with larger size
			local params = vim.lsp.util.make_position_params(nil, "utf-8")
			vim.lsp.buf_request(0, "textDocument/hover", params, function(_, result, _, _)
				if result and result.contents then
					-- Create a larger floating window with the documentation
					local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
					local bufnr = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
					vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
					
					-- Use fixed width instead of calculating from first line
					local width = 100  -- Fixed wider width 
					local height = math.min(#lines, 30)
					
					vim.api.nvim_open_win(bufnr, true, {
						relative = "cursor",
						width = width,
						height = height,
						row = 1,
						col = 0,
						style = "minimal",
						border = "rounded",
					})
				end
			end)
		end, {})
		
		-- Bind the fuller docs to a key
		vim.keymap.set("n", "<leader>K", "<cmd>ShowFullDocs<CR>", { desc = "Show Full Documentation" })
	end,
}
