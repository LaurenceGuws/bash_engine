-- Main plugin configuration file
return {
    -- UI Components
    require("plugins.ui.snacks.init"),
    require("plugins.ui.components.icons"),
    require("plugins.ui.components.statusline"),
    require("plugins.ui.components.which_key"),
    -- Theme management
    require("plugins.ui.theme.colors"),
    require("plugins.ui.theme.theme_ui"),
    require("plugins.ui.components.telescope_config"),
    -- Coding
    require("plugins.coding.lsp.init"),
    require("plugins.coding.git"),
    require("plugins.coding.treesitter"),
    require("plugins.coding.comment"),
    require("plugins.coding.languages.ansi.ansi"),
    require("plugins.coding.languages.markdown.markdown"),
}
