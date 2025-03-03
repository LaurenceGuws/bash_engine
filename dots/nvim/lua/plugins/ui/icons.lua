return {
  "echasnovski/mini.icons",
  version = false,
  event = "VeryLazy",
  config = function()
    require("mini.icons").setup({
      -- Configure icon groups for different use cases
      lsp = {
        error = "",
        warn = "",
        hint = "",
        info = "",
      },
      git = {
        added = "",
        changed = "",
        deleted = "",
      },
      filesystem = {
        directory = "",
        file = "",
      },
    })
  end,
} 