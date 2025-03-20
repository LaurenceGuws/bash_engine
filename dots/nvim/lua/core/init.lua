return {
  pcall(require, "core.options"),
  require("lazy").setup({ import = "plugins" }),
  pcall(require, "core.autocmds"),
  pcall(require, "core.keymaps"),
  pcall(require, "core.terminal"),
  (function() 
    local ok, highlights = pcall(require, "core.highlights")
    if ok and highlights then highlights.apply() end
  end)(),
  pcall(require, "core.theme_picker"),
  require("plugins.ui.notification_log")
}
