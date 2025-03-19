-- Code block focus outlines using a combination of methods
return {
  "echasnovski/mini.indentscope",
  version = false, -- Use latest version
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local indentscope = require("mini.indentscope")
    
    -- Use catppuccin colors for highlighting
    local catppuccin_colors = {
      purple = "#cba6f7",
      blue = "#89b4fa",
      pink = "#f5c2e7",
      green = "#a6e3a1",
      yellow = "#f9e2af",
      peach = "#fab387",
      lavender = "#b4befe",
    }
    
    -- Setup indentscope with simplest animation config
    indentscope.setup({
      -- Draw options
      draw = {
        -- Delay (in ms) between event and start of drawing scope indicator
        delay = 0,
        
        -- Simplify animation to ensure it works correctly
        -- Setting to nil disables animation
        animation = nil,
        
        -- Symbol priority. Increase to display over more decorations.
        priority = 2,
      },
      
      -- Symbol to be displayed at the beginning and end of scope
      symbol = "│",
      
      -- Options for scope visualization 
      options = {
        -- Type of scope visualization:
        -- - 'border' - add border on sides  
        -- - 'underline' - add underline below start line and above end line
        -- - 'both' - both 'border' and 'underline'
        -- - 'none' - nothing
        type = "both",
        
        -- Whether to show scope even for empty line
        empty_line = true,
        
        -- Compute the scope of current line only when initially needed
        init_at_cursor = false,
      },
      
      -- Symbol by which line with start of scope is indicated with 'underline' type
      symbol_start = "╭",
      
      -- Symbol by which line with end of scope is indicated with 'underline' type
      symbol_end = "╰",
      
      -- Which scopes to try first to show
      try_as_border = true,
    })
    
    -- Create custom highlights for current scope
    vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = catppuccin_colors.blue, bold = true })
    vim.api.nvim_set_hl(0, "MiniIndentscopeSymbolOff", { fg = catppuccin_colors.lavender, bold = false })
    
    -- Make special symbols for start and end of scope
    vim.api.nvim_set_hl(0, "MiniIndentscopeStart", { fg = catppuccin_colors.green, bold = true, underline = true })
    vim.api.nvim_set_hl(0, "MiniIndentscopeEnd", { fg = catppuccin_colors.green, bold = true, underline = true })
    
    -- Set which filetypes to exclude
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { 
        "help", 
        "dashboard", 
        "neo-tree", 
        "Trouble", 
        "trouble", 
        "lazy", 
        "mason", 
        "notify", 
        "toggleterm",
        "lazyterm",
      },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
    
    -- Add toggle keymaps
    vim.keymap.set("n", "<leader>tb", function()
      if vim.b.miniindentscope_disable then
        vim.b.miniindentscope_disable = false
        vim.notify("Block focus outlines enabled", vim.log.levels.INFO)
      else
        vim.b.miniindentscope_disable = true
        vim.notify("Block focus outlines disabled", vim.log.levels.INFO)
      end
    end, { desc = "Toggle block focus outlines" })
    
    -- After setup, add commands to manually operate indentscope
    vim.api.nvim_create_user_command("IndentscopeRefresh", function()
      indentscope.refresh()
    end, { desc = "Refresh indentscope" })
  end,
} 