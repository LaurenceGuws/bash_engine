return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		{
			"hrsh7th/cmp-nvim-lsp",
			lazy = false,
			priority = 1000, -- Load before everything else
		},
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-calc",
		"kristijanhusak/vim-dadbod-completion", -- DB completions
		"L3MON4D3/LuaSnip", -- Snippet engine
		"saadparwaiz1/cmp_luasnip", -- Luasnip completion source
		"onsails/lspkind.nvim", -- VSCode-like pictograms
		"hrsh7th/cmp-nvim-lua", -- Neovim Lua API completion
		"petertriho/cmp-git", -- Git completions
		"windwp/nvim-autopairs", -- Auto-close brackets, etc.
		"rafamadriz/friendly-snippets", -- Predefined snippets for many languages
		"MunifTanjim/nui.nvim", -- UI components
		{
			"L3MON4D3/LuaSnip",
			build = "make install_jsregexp", -- Required for variable transformations
			dependencies = { "rafamadriz/friendly-snippets" },
		},
		-- Adding dedicated documentation display plugin
		{
			"roobert/tailwindcss-colorizer-cmp.nvim",
			config = function()
				require("tailwindcss-colorizer-cmp").setup({
					color_square_width = 2,
				})
			end,
		},
		-- Add markdown rendering for documentation
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
		},
		-- Enhanced markdown preview for documentation
		"jghauser/follow-md-links.nvim",
		-- Improved hover documentation
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
	},
	event = "VeryLazy",
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")
		local luasnip = require("luasnip")

		-- Load snippets
		require("luasnip.loaders.from_vscode").lazy_load()

		-- Setup autopairs integration with cmp
		local autopairs = require("nvim-autopairs")
		autopairs.setup({
			check_ts = true, -- Use treesitter for better checking
			disable_filetype = { "TelescopePrompt" },
			fast_wrap = {
				map = "<M-e>", -- Alt+e to fast wrap
				chars = { "{", "[", "(", '"', "'" },
				pattern = string.gsub(" [%'%\"%>%]%)%}%,] ", "%s+", ""),
				end_key = "$",
				keys = "qwertyuiopzxcvbnmasdfghjkl",
				check_comma = true,
				highlight = "Search",
				highlight_grey = "Comment",
			},
		})

		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

		-- Get buffer source for special filetypes
		local get_buffers = function()
			local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
			if buf_ft == "sql" or buf_ft == "mysql" then
				return {
					name = "vim-dadbod-completion",
					priority = 1500, -- SQL gets top priority in SQL files
				}
			end
			return {
				name = "buffer",
				priority = 250,
			}
		end

		-- Custom function to determine if we should auto-select the first item
		-- local has_words_before = function()
		-- 	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
		-- 		return false
		-- 	end
		-- 	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		-- 	return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
		-- end

		-- Enhance documentation formatting with markdown support
		local format_documentation = function(documentation)
			if not documentation then
				return nil
			end

			if type(documentation) == "string" then
				return documentation
			end

			-- Handle LSP documentation format
			if documentation.kind == "markdown" then
				-- Process markdown for better display
				local content = documentation.value or ""
				-- Add proper spacing for markdown elements
				content = content:gsub("^%s+", ""):gsub("%s+$", "")
				return content
			elseif documentation.kind == "plaintext" then
				return documentation.value
			end

			-- Fallback for other formats
			return documentation.value
		end

		-- Enhanced formatting for completions with color support
		local format = function(entry, vim_item)
			local kind = lspkind.cmp_format({
				mode = "symbol_text",
				maxwidth = 50,
				ellipsis_char = "...",
				menu = {
					nvim_lsp = "[LSP]",
					nvim_lua = "[API]",
					luasnip = "[Snip]",
					buffer = "[Buf]",
					path = "[Path]",
					calc = "[Calc]",
					cmp_git = "[Git]",
					["vim-dadbod-completion"] = "[DB]",
				},
				before = function(entry, vim_item)
					-- Add thin space after kind icon
					vim_item.kind = string.format("%s %s", lspkind.presets.default[vim_item.kind], vim_item.kind)

					-- Add source
					vim_item.menu = ({
						nvim_lsp = "[LSP]",
						nvim_lua = "[Lua]",
						luasnip = "[Snip]",
						buffer = "[Buf]",
						path = "[Path]",
						calc = "[Calc]",
						cmp_git = "[Git]",
						["vim-dadbod-completion"] = "[DB]",
					})[entry.source.name]

					-- Enhanced documentation processing
					local documentation = entry.completion_item.documentation
					if documentation then
						vim_item.documentation = format_documentation(documentation)
					end

					return vim_item
				end,
			})(entry, vim_item)

			-- Apply tailwind colors if available
			local ok, tailwind_colors = pcall(require, "tailwindcss-colorizer-cmp")
			if ok then
				return tailwind_colors.formatter(entry, kind)
			else
				return kind
			end
		end

		-- Setup cmp with enhanced configuration
		cmp.setup({
			completion = {
				-- Disable automatic completion popup
				autocomplete = false,
				completeopt = "menu,menuone,noselect,noinsert",
				keyword_length = 1, -- Show completion after 1 character
			},

			-- Ensure items are properly preselected
			preselect = cmp.PreselectMode.Item,

			-- Visual customization
			window = {
				completion = {
					border = "rounded",
					winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
					scrollbar = true,
					col_offset = -3,
					side_padding = 1,
				},
				documentation = {
					border = "rounded",
					winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocBorder",
					scrollbar = true,
					max_height = 20, -- Increased from 15 to 20
					max_width = 120, -- Increased from 80 to 120 for more space
					-- Always show docs when available
					auto_open = true,
				},
			},

			-- Formatting
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = format,
			},

			-- Snippet configuration
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},

			-- Key mapping
			mapping = cmp.mapping.preset.insert({
				-- Custom Super-Tab functionality
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						-- Select next and ensure documentation is visible
						cmp.select_next_item({
							behavior = cmp.SelectBehavior.Select,
						})
						-- Force update documentation view
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>u", true, true, true), "n", true)
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						-- Pass through to insert a normal tab
						fallback()
					end
				end, { "i", "s" }),

				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						-- Select previous and ensure documentation is visible
						cmp.select_prev_item({
							behavior = cmp.SelectBehavior.Select,
						})
						-- Force update documentation view
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>u", true, true, true), "n", true)
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),

				-- Special Ctrl+Space mapping for priority LSP listings
				["<C-Space>"] = cmp.mapping(function()
					if cmp.visible() then
						cmp.abort()
					else
						cmp.complete({
							config = {
								sources = {
									{ name = "nvim_lsp", priority = 1000 },
									{ name = "nvim_lua", priority = 900 },
									{ name = "luasnip", priority = 750 },
									{ name = "vim-dadbod-completion", priority = 700 },
									{ name = "calc", priority = 400 },
									{ name = "path", priority = 300 },
									{ name = "buffer", priority = 200 },
								},
							},
						})
					end
				end, { "i" }),

				-- Accept completion
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = false, -- Only confirm explicit selections
				}),

				-- Scroll docs - using VSCode-like mappings for consistency
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-u>"] = cmp.mapping.scroll_docs(-10), -- Larger jumps
				["<C-d>"] = cmp.mapping.scroll_docs(10),  -- Larger jumps

				-- Cancel completion
				["<C-e>"] = cmp.mapping.abort(),

				-- Trigger completion manually (if autocomplete is disabled)
				["<C-k>"] = cmp.mapping.complete(),

				-- Always show documentation when navigating
				["<C-n>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
					else
						fallback()
					end
				end),
				["<C-p>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
					else
						fallback()
					end
				end),
				
				-- Add mapping to explicitly open documentation
				["<C-h>"] = cmp.mapping(function()
					if cmp.visible_docs() then
						cmp.close_docs()
					else
						cmp.open_docs()
					end
				end, { "i", "s" }),
			}),

			-- Sources in priority order
			sources = cmp.config.sources({
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "nvim_lua", priority = 900 },
				{ name = "luasnip", priority = 750 },
				{ name = "vim-dadbod-completion", priority = 700 },
				{ name = "calc", priority = 400 },
				{ name = "path", priority = 300, option = { trailing_slash = true } },
				get_buffers(), -- Dynamic buffer source
			}),

			-- Experimental features
			experimental = {
				ghost_text = {
					hl_group = "CmpGhostText",
				},
			},

			-- Sorting configuration for more relevant completions
			sorting = {
				priority_weight = 2.0,
				comparators = {
					-- Deprioritize items containing "deprecated"
					function(entry1, entry2)
						-- Safely check if documentation exists and contains "deprecated"
						local function is_deprecated(entry)
							if not entry then
								return false
							end
							local doc = entry:get_documentation()
							if not doc then
								return false
							end

							-- Handle documentation potentially being a table
							if type(doc) == "table" then
								local text = doc.value or ""
								return type(text) == "string" and text:find("deprecated") ~= nil
							end

							-- Handle documentation being a string
							return type(doc) == "string" and doc:find("deprecated") ~= nil
						end

						local entry1_deprecated = is_deprecated(entry1)
						local entry2_deprecated = is_deprecated(entry2)

						if entry1_deprecated and not entry2_deprecated then
							return false
						elseif not entry1_deprecated and entry2_deprecated then
							return true
						else
							return nil
						end
					end,
					-- Other built-in comparators
					cmp.config.compare.exact,
					cmp.config.compare.score,
					cmp.config.compare.recently_used,
					cmp.config.compare.locality,
					cmp.config.compare.kind,
					cmp.config.compare.sort_text,
					cmp.config.compare.length,
					cmp.config.compare.order,
				},
			},
		})

		-- Enable completion in command mode
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
				{ name = "cmdline" },
			}),
		})

		-- Enable completion in search mode
		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		-- Add special handling for filetypes
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "sql", "mysql", "plsql" },
			callback = function()
				cmp.setup.buffer({
					sources = cmp.config.sources({
						{ name = "vim-dadbod-completion", priority = 1000 },
						{ name = "buffer", priority = 500 },
					}),
				})
			end,
		})

		-- Git completion for commit messages
		local has_cmp_git, cmp_git = pcall(require, "cmp_git")
		if has_cmp_git then
			cmp_git.setup()

			-- Add git source to commit filetype
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "gitcommit", "NeogitCommitMessage" },
				callback = function()
					cmp.setup.buffer({
						sources = cmp.config.sources({
							{ name = "cmp_git" },
							{ name = "buffer" },
						}),
					})
				end,
			})
		end

		-- Set up custom highlighting for completion menu
		vim.api.nvim_exec(
			[[
      highlight! link CmpItemAbbrDefault Normal
      highlight! link CmpItemAbbr Normal
      highlight! link CmpItemAbbrMatchDefault Title
      highlight! link CmpItemAbbrMatch Title
      highlight! link CmpItemAbbrMatchFuzzyDefault Title
      highlight! link CmpItemAbbrMatchFuzzy Title
      highlight! link CmpItemMenuDefault Comment
      highlight! link CmpItemMenu Comment
      highlight! PmenuSel guibg=#363a4f guifg=NONE
      highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
      highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
      highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
      highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
      highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
      highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
      highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
      highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
    ]],
			false
		)

		-- Set up standard LSP handlers with borders and enhanced markdown support
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = "rounded",
			-- Add max width and height for better documentation display
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
