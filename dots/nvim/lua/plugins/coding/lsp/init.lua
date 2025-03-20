-- Main LSP entry point with correct loading order
return {
  -- All configurations have been migrated to their respective files:
  -- 1. cmp-nvim-lsp to completions.lua with priority 1000
  -- 2. mason.nvim to mason.lua with priority 900
  -- 3. mason-lspconfig.nvim and server configs to mason.lua with priority 800
  -- 4. nvim-lspconfig to lspconfig.lua with priority 700
  
  require("plugins.coding.lsp.completions"), -- Includes cmp-nvim-lsp with priority 1000
  require("plugins.coding.lsp.mason"),       -- Includes mason.nvim (900) and mason-lspconfig.nvim (800)
  require("plugins.coding.lsp.lspconfig"),   -- Core LSP configuration 
  require("plugins.coding.lsp.cmp"),          -- Completion system
  require("plugins.coding.lsp.treesitter")   -- Includes treesitter for syntax highlighting
}
