return {
	"nvimdev/lspsaga.nvim",
	after = "nvim-lspconfig",
	config = function()
		require("lspsaga").setup({
			lightbulb = { sign = false },
			ui = {
				code_action = "",
			},
		})
	end,
	-- Rename, Finder, Outline
	vim.keymap.set({ "n", "v" }, "<leader>lr", ":Lspsaga rename<CR>", { desc = "Rename Symbol" }),
	vim.keymap.set({ "n", "v" }, "<leader>lf", ":Lspsaga finder<CR>", { desc = "LSP Finder" }),
	vim.keymap.set({ "n", "v" }, "<leader>lo", ":Lspsaga outline<CR>", { desc = "Document Outline" }),

	-- Type Hierarchy
	vim.keymap.set({ "n", "v" }, "<leader>lS", ":Lspsaga subtypes<CR>", { desc = "Subtypes Hierarchy" }),
	vim.keymap.set({ "n", "v" }, "<leader>lT", ":Lspsaga supertypes<CR>", { desc = "Supertypes Hierarchy" }),

	-- Code Actions and Definitions
	vim.keymap.set({ "n", "v" }, "<leader>la", ":Lspsaga code_action<CR>", { desc = "Code Action" }),
	vim.keymap.set({ "n", "v" }, "<leader>ld", ":Lspsaga goto_definition<CR>", { desc = "Go to Definition" }),
	vim.keymap.set({ "n", "v" }, "<leader>lD", ":Lspsaga peek_definition<CR>", { desc = "Peek Definition" }),
	vim.keymap.set({ "n", "v" }, "<leader>ly", ":Lspsaga goto_type_definition<CR>", { desc = "Go to Type Definition" }),
	vim.keymap.set({ "n", "v" }, "<leader>lY", ":Lspsaga peek_type_definition<CR>", { desc = "Peek Type Definition" }),

	-- Diagnostics
	vim.keymap.set({ "n", "v" }, "<leader>lj", ":Lspsaga diagnostic_jump_next<CR>", { desc = "Next Diagnostic" }),
	vim.keymap.set({ "n", "v" }, "<leader>lk", ":Lspsaga diagnostic_jump_prev<CR>", { desc = "Previous Diagnostic" }),
	vim.keymap.set({ "n", "v" }, "<leader>ll", ":Lspsaga show_line_diagnostics<CR>", { desc = "Line Diagnostics" }),
	vim.keymap.set({ "n", "v" }, "<leader>lB", ":Lspsaga show_buf_diagnostics<CR>", { desc = "Buffer Diagnostics" }),
	vim.keymap.set({ "n", "v" }, "<leader>lW", ":Lspsaga show_workspace_diagnostic<CR>", { desc = "Workspace Diagnostics" }),
	vim.keymap.set({ "n", "v" }, "<leader>lx", ":Lspsaga show_cursor_diagnostics<CR>", { desc = "Cursor Diagnostics" }),

	-- Misc
	vim.keymap.set({ "n", "v" }, "<leader>lh", ":Lspsaga hover_doc<CR>", { desc = "Hover Documentation" }),
	vim.keymap.set({ "n", "v" }, "<leader>lp", ":Lspsaga project_replace<CR>", { desc = "Project Replace" }),
	vim.keymap.set({ "n", "v" }, "<leader>li", ":Lspsaga incoming_calls<CR>", { desc = "Incoming Calls" }),
	vim.keymap.set({ "n", "v" }, "<leader>lu", ":Lspsaga outgoing_calls<CR>", { desc = "Outgoing Calls" }),
	vim.keymap.set({ "n", "v" }, "<leader>lt", ":Lspsaga term_toggle<CR>", { desc = "Toggle Terminal" }),
	vim.keymap.set({ "n", "v" }, "<leader>lv", ":Lspsaga winbar_toggle<CR>", { desc = "Toggle Winbar" }),
	vim.keymap.set({ "n", "v" }, "<leader>lz", ":Lspsaga open_log<CR>", { desc = "Open LSP Log" }),


}
