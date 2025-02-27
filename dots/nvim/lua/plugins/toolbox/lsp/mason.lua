return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim", -- LSP
    "jay-babu/mason-null-ls.nvim",      -- Linters & Formatters
    "mfussenegger/nvim-dap",            -- Debug Adapter Protocol (DAP)
    "jay-babu/mason-nvim-dap.nvim",     -- Mason DAP Support
    "nvimtools/none-ls.nvim",           -- None-LS (formerly Null-LS)
  },
  lazy = false,
  config = function()
    require("mason").setup()

    --  Manually install only the most useful LSPs
    local mason_lspconfig = require("mason-lspconfig")
    mason_lspconfig.setup({
      ensure_installed = {
          "lua_ls",      -- Lua
          "pyright",     -- Python
          "bashls",      -- Bash
          "jsonls",      -- JSON
          "yamlls",      -- YAML
          "gopls",       -- Go
          "clangd",      -- C/C++
          "rust_analyzer", -- Rust
          "zls"          -- Zig (Added)
      },

      automatic_installation = true,
    })

    --  Manually install only necessary linters & formatters
    local mason_null_ls = require("mason-null-ls")
    mason_null_ls.setup({
      ensure_installed = {
        "stylua",  -- Lua formatter
        "prettier", -- JS/TS formatter
        "black",    -- Python formatter
        "eslint_d", -- JS/TS linter
        "shellcheck", -- Shell script linter
      },
      automatic_installation = true,
    })

    --  Manually install only useful DAPs
    local mason_dap = require("mason-nvim-dap")
    mason_dap.setup({
      ensure_installed = {
        "python",   -- Python Debugging
        "delve",    -- Go Debugging
        "cppdbg",   -- C++ Debugging
      },
      automatic_installation = true,
    })
  end,
}

