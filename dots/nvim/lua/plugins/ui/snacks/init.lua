-- Main snacks.nvim plugin spec

-- Import submodules
local config = require("plugins.ui.snacks.config")
local keymaps = require("plugins.ui.snacks.keymaps")
local setup = require("plugins.ui.snacks.setup")

-- Build and return the plugin spec
return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    enabled = true,
    opts = config,
    init = setup.init,
    keys = keymaps.keys,
}
