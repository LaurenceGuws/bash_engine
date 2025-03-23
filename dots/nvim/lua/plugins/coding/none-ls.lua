-- Setup none-ls (replacement for null-ls)
return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		-- none-ls.nvim still exposes itself as null-ls for compatibility
		local null_ls = require("null-ls")

		-- Helper function to check if a command is available
		local function command_exists(cmd)
			local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
			if not handle then
				return false
			end

			local result = handle:read("*a")
			handle:close()
			return result ~= ""
		end

		-- Sources to be registered
		local sources = {}

		-- Only register formatters/linters that are actually installed

		-- Formatters
		if command_exists("stylua") then
			table.insert(sources, null_ls.builtins.formatting.stylua)
		end

		if command_exists("prettier") then
			table.insert(sources, null_ls.builtins.formatting.prettier)
		end

		if command_exists("black") then
			table.insert(sources, null_ls.builtins.formatting.black)
		end

		if command_exists("isort") then
			table.insert(sources, null_ls.builtins.formatting.isort)
		end

		if command_exists("shfmt") then
			table.insert(sources, null_ls.builtins.formatting.shfmt)
		end

		-- Linters
		-- Comment out eslint to prevent error
		-- if command_exists("eslint") then
		--   table.insert(sources, null_ls.builtins.diagnostics.eslint)
		-- end

		-- Comment out shellcheck to prevent error
		-- if command_exists("shellcheck") then
		--   table.insert(sources, null_ls.builtins.diagnostics.shellcheck)
		-- end

		-- Comment out flake8 to prevent error
		-- if command_exists("flake8") then
		--   table.insert(sources, null_ls.builtins.diagnostics.flake8)
		-- end

		-- Add diagnostics sources
		if command_exists("codespell") then
			table.insert(sources, null_ls.builtins.diagnostics.codespell)
		end

		-- Comment out luacheck to prevent errors
		-- if command_exists("luacheck") then
		--   table.insert(sources, null_ls.builtins.diagnostics.luacheck)
		-- end

		-- Code actions (gitsigns doesn't need a command check)
		if package.loaded["gitsigns"] then
			table.insert(sources, null_ls.builtins.code_actions.gitsigns)
		end

		-- Register the formatters/linters that are available
		null_ls.setup({
			sources = sources,
			-- Use the current LSP client capabilities
			on_attach = function(client, bufnr)
				-- You can uncomment this if you want automatic formatting on save
				-- if client.supports_method("textDocument/formatting") then
				--   local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
				--   vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
				--   vim.api.nvim_create_autocmd("BufWritePre", {
				--     group = augroup,
				--     buffer = bufnr,
				--     callback = function()
				--       vim.lsp.buf.format({ bufnr = bufnr })
				--     end,
				--   })
				-- end
			end,
			-- Debug level
			debug = false,
		})

		-- Log the sources that were registered
		local registered = {}
		for _, source in ipairs(sources) do
			table.insert(registered, source.name)
		end

		if #registered > 0 then
			vim.notify("none-ls registered: " .. table.concat(registered, ", "), vim.log.levels.INFO)
		else
			vim.notify(
				"none-ls: No formatters or linters found. Install some with your package manager.",
				vim.log.levels.WARN
			)
		end
	end,
}
