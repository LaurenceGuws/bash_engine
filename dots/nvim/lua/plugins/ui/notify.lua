return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  config = function()
    -- Try to use a color from the current colorscheme, falling back to a dark gray
    local bg_color = "#1e1e2e" -- A dark background that works well with many themes
    
    -- Setup notify with proper background
    require("notify").setup({
      background_colour = bg_color,
      render = "default",
      stages = "fade",
      timeout = 3000,
      max_width = 80,
      icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        DEBUG = "",
        TRACE = "✎",
      },
    })
    
    -- Set as default notification handler
    vim.notify = require("notify")
  end,
} 