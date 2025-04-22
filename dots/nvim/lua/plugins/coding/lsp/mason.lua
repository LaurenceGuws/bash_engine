return {
	"williamboman/mason.nvim",
	dependencies = {
		{
			"williamboman/mason-lspconfig.nvim", -- LSP
			lazy = false,
			priority = 800,
			dependencies = {
				"folke/neodev.nvim",
				"b0o/schemastore.nvim",
				"folke/trouble.nvim",
			},
		},
		"mfussenegger/nvim-dap", -- Debug Adapter Protocol (DAP)
		"jay-babu/mason-nvim-dap.nvim", -- Mason DAP Support
	},
	lazy = false,
	priority = 900,
	config = function()
		-- Setup Mason
		require("mason").setup({
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
				keymaps = {
					toggle_package_expand = "<CR>",
					install_package = "i",
					update_package = "u",
					check_package_version = "c",
					update_all_packages = "U",
					check_outdated_packages = "C",
					uninstall_package = "X",
					cancel_installation = "<C-c>",
					apply_language_filter = "/", -- Change filter to use '/' instead of Ctrl+F
				},
				check_outdated_packages = {
					-- Disable auto-checking to avoid pager issues
					auto_check = false,
				},
			},
			max_concurrent_installers = 4,
			log_level = vim.log.levels.DEBUG,
		})

		-- Create custom command for filtering in Mason
		vim.api.nvim_create_user_command("MasonFilter", function(opts)
			-- Get the Mason window if it exists
			local mason_win = nil
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.api.nvim_buf_get_option(buf, "filetype") == "mason" then
					mason_win = win
					break
				end
			end

			if mason_win then
				-- Focus the Mason window
				vim.api.nvim_set_current_win(mason_win)
				-- Send the / key to activate filter
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("/", true, false, true), "n", true)
			else
				vim.notify("Mason window not found. Open Mason first with :Mason", vim.log.levels.WARN)
			end
		end, {})

		-- Create keymap in Mason buffers for easier filtering
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "mason",
			callback = function(event)
				vim.keymap.set("n", "<C-f>", ":", {
					buffer = event.buf,
					silent = true,
					noremap = true,
					callback = function()
						vim.cmd("MasonFilter")
					end,
					desc = "Mason Filter",
				})
			end,
		})

		-- Directly suppress health check warnings for unused languages
		do
			-- Get the health check functions with fallbacks for Neovim version differences
			local health_warn = vim.health.warn or vim.health.report_warn

			-- Store the original health check function
			local orig_health_warn = health_warn

			-- Create a pattern list of warnings to suppress
			local suppress_patterns = {
				"perl",
				"ruby",
				"node",
				"python2",
				"python3.10",
			}

			-- Override the warn function to filter out certain provider warnings
			vim.health.warn = function(msg, ...)
				if msg then
					for _, pattern in ipairs(suppress_patterns) do
						if msg:match(pattern) then
							-- Don't report this warning
							return
						end
					end
				end
				-- Pass through to original function for all other warnings
				orig_health_warn(msg, ...)
			end

			-- Ensure the report_warn alias works too
			if vim.health.report_warn then
				vim.health.report_warn = vim.health.warn
			end
		end

		-- Essential LSPs for integration development
		local mason_lspconfig = require("mason-lspconfig")

		-- Adding servers configuration from init.lua
		-- These server settings will be used in setup_handlers
		local servers = {
			lua_ls = {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			},
			pyright = {},
			jdtls = {},
			bashls = {},
			html = {},
			cssls = {},
			jsonls = {},
			yamlls = {},
			zls = {},
			clangd = {},
		}

		mason_lspconfig.setup({
			ensure_installed = vim.tbl_keys(servers), -- Use the servers from init.lua
			automatic_installation = true,
		})

		-- Add this configuration from init.lua
		-- Set up capabilities for autocompletion
		local capabilities
		local has_blink, blink_cmp = pcall(require, "blink.cmp")
		
		if has_blink then
			-- Create standard capabilities for blink.cmp
			capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem = {
				documentationFormat = { "markdown", "plaintext" },
				snippetSupport = true,
				preselectSupport = true,
				insertReplaceSupport = true,
				labelDetailsSupport = true,
				deprecatedSupport = true,
				commitCharactersSupport = true,
				tagSupport = { valueSet = { 1 } },
				resolveSupport = {
					properties = {
						"documentation",
						"detail",
						"additionalTextEdits",
					},
				},
			}
		else
			-- Fallback to vim's default capabilities if blink.cmp is not available
			capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true
		end

		-- Setup all servers - added from init.lua
		mason_lspconfig.setup_handlers({
			function(server_name)
				require("lspconfig")[server_name].setup({
					capabilities = capabilities,
					-- Use existing settings if available
					on_attach = function(client, bufnr)
						vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
						vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
						vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
						vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })

						-- Log that the LSP attached
						vim.notify("LSP " .. client.name .. " attached to buffer", vim.log.levels.INFO)

						-- Force showing diagnostics
						vim.diagnostic.show()
					end,
				})
			end,
		})

		-- Setup diagnostic display from init.lua
		vim.diagnostic.config({
			virtual_text = false, -- Disable inline diagnostics by default
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		-- Configure none-ls for additional linting/formatting
		local has_none_ls, null_ls = pcall(require, "null-ls")
		if not has_none_ls then
			vim.notify("none-ls not found, linting and formatting may be limited", vim.log.levels.WARN)
			return
		end

		-- None-ls is now set up in its own plugin file (lua/plugins/coding/none-ls.lua)
		-- Here we only need to configure the on_attach functionality for formatting

		-- Automatically format on save for specific file types
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "lua", "python", "javascript", "typescript", "json", "html", "css", "yaml" },
			callback = function(event)
				local bufnr = event.buf

				-- Only set up if none-ls is available
				if has_none_ls then
					-- Format on save autocmd
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							-- Only format if explicitly enabled for this buffer
							if vim.b.format_on_save then
								vim.lsp.buf.format({ async = false })
							end
						end,
					})

					-- Create command to toggle format on save
					vim.api.nvim_buf_create_user_command(bufnr, "ToggleFormatOnSave", function()
						vim.b.format_on_save = not vim.b.format_on_save
						print("Format on save " .. (vim.b.format_on_save and "enabled" or "disabled"))
					end, { desc = "Toggle format on save" })

					-- Enable format on save by default
					vim.b.format_on_save = true
				end
			end,
		})

		-- Manually install only useful DAPs
		local mason_dap = require("mason-nvim-dap")
		mason_dap.setup({
			ensure_installed = {
				"python", -- Python Debugging
				"delve", -- Go Debugging
				"cppdbg", -- C++ Debugging
				"java-debug-adapter", -- Java Debugging
				"js-debug-adapter", -- JavaScript/TypeScript Debugging
			},
			automatic_installation = true,
			handlers = {
				function(config)
					-- All sources with no handler get passed here
					require("mason-nvim-dap").default_setup(config)
				end,
			},
		})
	end,
}
