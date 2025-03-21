-- Main plugin configuration file
return {
  -- UI Components
  require("plugins.ui.colors"),
  require("plugins.ui.bufferline"),
  require("plugins.ui.statusline"),
  require("plugins.ui.icons"),
  -- Explorer config is a special case
  require("plugins.ui.exp.nvim-tree"),
  require("plugins.ui.fuzzy"),
  require("plugins.ui.markdown"),
  require("plugins.ui.which_key"),
  require("plugins.ui.zen-mode"),
  require("plugins.ui.block_focus"),
  -- Load notification_log module separately
  -- require("plugins.ui.notification_log"),

  -- Coding
  require("plugins.coding.comment"),
  require("plugins.coding.git"),
  require("plugins.coding.lsp.init"),
  require("plugins.coding.completion"),
  require("plugins.coding.dap_config"),
  require("plugins.coding.ansi"),
  -- Integrations
  require("plugins.integrations.kubectl"),
  require("plugins.integrations.dadbod"),
  -- require("plugins.integrations.docker"),
  require("plugins.integrations.ai.avante"),
}
