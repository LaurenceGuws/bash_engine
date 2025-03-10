-- Main plugin configuration file
return {
  -- UI Components
  require("plugins.ui.colors"),
  require("plugins.ui.bufferline"),
  require("plugins.ui.statusline"),
  require("plugins.ui.noice"),
  require("plugins.ui.notify"),
  require("plugins.ui.icons"),
  require("plugins.ui.explorer"),
  require("plugins.ui.fuzzy"),
  require("plugins.ui.markdown"),
  require("plugins.ui.which_key"),
  require("plugins.ui.zen-mode"),
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
