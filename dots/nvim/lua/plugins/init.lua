-- Main plugin configuration file
return {
	-- UI Components
	require("plugins.ui.which_key"),
	require("plugins.ui.theme_ui"),
	require("plugins.ui.snacks"),
	require("plugins.ui.colors"),
	require("plugins.ui.statusline"),
	-- Coding
	require("plugins.coding.lsp.init"),
	require("plugins.coding.completions"),
	require("plugins.coding.none-ls"),
	require("plugins.coding.git"),
	require("plugins.coding.comment"),
	require("plugins.coding.dap_config"),
	require("plugins.coding.ansi"),
}
