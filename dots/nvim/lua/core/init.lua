return {
	pcall(require, "core.options"),
	require("lazy").setup({ import = "plugins" }),
	pcall(require, "core.autocmds"),
	pcall(require, "core.keymaps"),
}
