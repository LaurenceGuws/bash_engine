return {
	"neovim/nvim-lspconfig",
	"mfussenegger/nvim-dap",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"folke/neodev.nvim", -- Better Lua development
		"b0o/schemastore.nvim", -- JSON schema support
		"folke/trouble.nvim", -- Better diagnostics display
	},
	lazy = false, -- Load LSP config immediately
	priority = 700, -- Updated from 90 to 700 to match init.lua
	config = function()
		local lspconfig = require("lspconfig")
		local util = require("lspconfig.util")

		-- Add patch for the nil table error in vim.lsp._dynamic
		-- This fixes the "bad argument #1 to 'ipairs' (table expected, got nil)" error
		local dynamic_module = package.loaded["vim.lsp._dynamic"] or require("vim.lsp._dynamic")
		if dynamic_module then
			local original_unregister = dynamic_module.unregister
			dynamic_module.unregister = function(client_id, reg_name)
				-- Guard against nil registration table
				local client = vim.lsp.get_client_by_id(client_id)
				if not client or not client.dynamic_capabilities or not client.dynamic_capabilities.registrations then
					return
				end

				-- Call original function with proper safeguard
				if client.dynamic_capabilities.registrations[reg_name] then
					return original_unregister(client_id, reg_name)
				end
			end
		end

		-- Command to show LSP logs
		vim.api.nvim_create_user_command("LspLog", function()
			vim.cmd("edit " .. vim.lsp.get_log_path())
		end, { desc = "Open LSP log file" })

		-- Print to emphasize LSP config is loading
		vim.notify("LSP configuration loading...", vim.log.levels.INFO)

		-- Setup neodev for better Lua development
		require("neodev").setup({
			library = { plugins = { "nvim-dap-ui" }, types = true },
		})

		-- Set up Trouble for better diagnostics display
		require("trouble").setup({
			icons = false,
			fold_open = "v",
			fold_closed = ">",
			indent_lines = false,
			signs = {
				error = "E",
				warning = "W",
				hint = "H",
				information = "I",
			},
			use_diagnostic_signs = false,
		})

		-- Define enhanced capabilities for nvim-cmp completion
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		-- Add workspace capabilities for advanced features
		capabilities.workspace = capabilities.workspace or {}
		capabilities.workspace.didChangeWatchedFiles = {
			dynamicRegistration = true,
		}
		capabilities.textDocument = capabilities.textDocument or {}
		capabilities.textDocument.completion = capabilities.textDocument.completion or {}
		capabilities.textDocument.completion.completionItem = capabilities.textDocument.completion.completionItem or {}
		capabilities.textDocument.completion.completionItem.snippetSupport = true
		capabilities.textDocument.completion.completionItem.preselectSupport = true
		capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
		capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
		capabilities.textDocument.completion.completionItem.deprecatedSupport = true
		capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
		capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
		capabilities.textDocument.completion.completionItem.resolveSupport = {
			properties = {
				"documentation",
				"detail",
				"additionalTextEdits",
			},
		}

		-- Add format sync capability
		capabilities.documentFormattingProvider = true

		-- Enhanced on_attach function with robust error handling
		local on_attach = function(client, bufnr)
			local opts = { noremap = true, silent = true }
			local keymap = vim.api.nvim_buf_set_keymap

			-- Set buffer-specific options
			vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

			-- Core LSP functionality
			keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
			keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
			keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
			keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
			keymap(bufnr, "n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
			keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
			keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
			keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
			keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
			keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", opts)
			keymap(bufnr, "n", "<leader>ws", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)

			-- Diagnostics
			keymap(
				bufnr,
				"n",
				"[d",
				"<cmd>lua vim.diagnostic.goto_prev({severity = {min = vim.diagnostic.severity.WARN}})<CR>",
				opts
			)
			keymap(
				bufnr,
				"n",
				"]d",
				"<cmd>lua vim.diagnostic.goto_next({severity = {min = vim.diagnostic.severity.WARN}})<CR>",
				opts
			)
			keymap(
				bufnr,
				"n",
				"[e",
				"<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>",
				opts
			)
			keymap(
				bufnr,
				"n",
				"]e",
				"<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>",
				opts
			)
			keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
			keymap(bufnr, "n", "<leader>tt", "<cmd>TroubleToggle<CR>", opts)
			keymap(bufnr, "n", "<leader>td", "<cmd>TroubleToggle document_diagnostics<CR>", opts)
			keymap(bufnr, "n", "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<CR>", opts)

			-- Turn on inlay hints for supported servers
			if client.server_capabilities.inlayHintProvider and vim.fn.has("nvim-0.10.0") == 1 then
				vim.lsp.inlay_hint.enable(bufnr, true)
			elseif client.server_capabilities.inlayHintProvider then
				-- Fallback for older Neovim versions
				vim.lsp.buf.inlay_hint(bufnr, true)
			end

			-- Auto-format on save if the client supports it
			if client.server_capabilities.documentFormattingProvider then
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						-- Try to format
						local success, err = pcall(vim.lsp.buf.format, { async = false, bufnr = bufnr })
						if not success and err then
							-- Print error but don't interrupt the save
							vim.notify("Format error: " .. tostring(err), vim.log.levels.WARN)
						end
					end,
				})
			end

			-- Give the user feedback about which LSP connected
			vim.notify(string.format("LSP [%s] attached", client.name), vim.log.levels.INFO)
		end

		-- Customize diagnostics display
		vim.diagnostic.config({
			virtual_text = {
				prefix = "●", -- Use a simple dot as prefix
				source = "if_many", -- Show source only if multiple
				severity = {
					min = vim.diagnostic.severity.HINT, -- Show all diagnostics including hints
				},
				spacing = 4, -- Add more space before the diagnostic text
				format = function(diagnostic)
					if diagnostic.severity == vim.diagnostic.severity.ERROR then
						return string.format("ERROR: %s", diagnostic.message)
					elseif diagnostic.severity == vim.diagnostic.severity.WARN then
						return string.format("WARNING: %s", diagnostic.message)
					end
					return diagnostic.message
				end,
			},
			float = {
				source = "always", -- Always show source in float window
				format = function(diagnostic)
					local code = diagnostic.code
						or diagnostic.user_data and diagnostic.user_data.lsp and diagnostic.user_data.lsp.code
					if not code then
						return string.format("%s", diagnostic.message)
					end
					return string.format("%s [%s]", diagnostic.message, code)
				end,
			},
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		-- Set custom diagnostic signs
		local signs = { Error = "■", Warn = "▲", Hint = "●", Info = "→" }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end

		-- Add JSON schemas for better intelligence
		local json_schemas = require("schemastore").json.schemas({
			select = {
				"package.json",
				"tsconfig.json",
				"docker-compose.yml",
				".github/workflows/workflow",
				".eslintrc",
				"pom.xml",
				"manifest.json",
				"GitHub Action",
				"Dependabot",
				"AWS CloudFormation",
				"ansible-playbook",
				"openapi.json",
				"swagger.json",
			},
		})

		-- Configure LSP servers with specialized setups for integration development
		-- BASE SERVER CONFIG
		local server_configs = {
			-- Web Development
			html = { capabilities = capabilities, on_attach = on_attach },
			cssls = { capabilities = capabilities, on_attach = on_attach },
			tsserver = {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
						},
					},
				},
			},

			-- DevOps-related
			dockerls = { capabilities = capabilities, on_attach = on_attach },
			helm_ls = {
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "helm" },
				cmd = { "helm_ls", "serve" },
			},
			yamlls = {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					yaml = {
						schemas = {
							["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
							["https://raw.githubusercontent.com/aws/serverless-application-model/develop/samtranslator/schema/schema.json"] = "template.yaml",
							["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.yml",
							["kubernetes"] = "/*.k8s.yaml",
							["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.0-standalone/all.json"] = {
								"/*.yaml",
								"/*.yml",
							},
							["https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json/helmfile.json"] = "helmfile*.{yaml,yml}",
							["https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json/chart.json"] = "Chart.{yaml,yml}",
							["https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json/kustomization.json"] = "kustomization.{yaml,yml}",
						},
						format = {
							enable = true,
						},
						validate = true,
						completion = true,
						hover = true,
						customTags = {
							"!include scalar",
							"!reference sequence",
							"!helm-template sequence",
							"!helm-include scalar",
						},
						disableDefaultProperties = true,
					},
				},
				filetypes = { "yaml", "yml", "helm" },
			},

			-- Data Integration
			jsonls = {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					json = {
						schemas = json_schemas,
						validate = { enable = true },
					},
				},
			},
			sqlls = { capabilities = capabilities, on_attach = on_attach },

			-- Programming Languages
			lua_ls = {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
						hint = { enable = true },
					},
				},
			},
			pyright = {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							autoImportCompletions = true,
							diagnosticMode = "workspace",
						},
					},
				},
			},
			jdtls = { capabilities = capabilities, on_attach = on_attach },
			bashls = { capabilities = capabilities, on_attach = on_attach },
			zls = {
				autostart = true,
				on_attach = on_attach,
				capabilities = capabilities,
				cmd = { "zls" },
				filetypes = { "zig", "zon" },
				root_dir = util.root_pattern("zls.json", "build.zig", ".git"),
				settings = {
					zls = {
						enable_autofix = true,
						enable_inlay_hints = true,
						warn_style = true,
					},
				},
			},
			clangd = {
				autostart = true,
				on_attach = on_attach,
				capabilities = capabilities,
				cmd = { "clangd" },
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
				root_dir = util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
				settings = {
					clangd = {
						checkUpdates = true,
						fallbackFlags = { "-std=c11" },
						suggestMissingIncludes = true,
						headerInsertion = "iwyu",
					},
				},
			},
			rust_analyzer = {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						checkOnSave = { command = "clippy" },
						inlayHints = {
							chainingHints = { enable = true },
							parameterHints = { enable = true },
							typeHints = { enable = true },
						},
					},
				},
			},
		}

		-- Set up the LSP servers with error handling
		for server_name, config in pairs(server_configs) do
			if lspconfig[server_name] then
				local success, err = pcall(function()
					lspconfig[server_name].setup(config)
				end)

				if not success then
					vim.notify(
						string.format("Failed to set up LSP server %s: %s", server_name, err),
						vim.log.levels.ERROR
					)
				end
			else
				vim.notify(string.format("LSP server %s not available", server_name), vim.log.levels.WARN)
			end
		end

		-- Integration development-specific tools (API-oriented)
		-- Auto-detect project types and adjust LSP configs
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
			callback = function()
				local filename = vim.fn.expand("%:t")
				local extension = vim.fn.expand("%:e")
				local filetype = vim.bo.filetype

				-- Check for API development (OpenAPI/Swagger)
				if
					filename:match("swagger")
					or filename:match("openapi")
					or (extension == "json" or extension == "yaml" or extension == "yml")
						and (vim.fn.getline(1):match("swagger") or vim.fn.getline(1):match("openapi"))
				then
					vim.notify("API documentation detected - enabling API development features", vim.log.levels.INFO)

					-- We could add specialized configurations here for API development
					-- e.g., start a local swagger UI, load specialized capabilities, etc.
				end

				-- Check for message queue/integration patterns
				if
					vim.fn.findfile("docker-compose.yml", ".;") ~= ""
						and vim.fn.readfile(vim.fn.findfile("docker-compose.yml", ".;")):join():match("kafka")
					or vim.fn.readfile(vim.fn.findfile("docker-compose.yml", ".;")):join():match("rabbitmq")
				then
					vim.notify("Integration messaging detected - enabling queue-related features", vim.log.levels.INFO)

					-- Could add specialized MQ-related tools here
				end
			end,
		})
	end,
}
