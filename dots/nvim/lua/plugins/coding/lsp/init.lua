-- Main LSP entry point with correct loading order
return {
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = false,
    priority = 1000, -- Load before everything else
  },
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 900,
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          },
        },
        log_level = vim.log.levels.DEBUG,
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    priority = 800,
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "folke/neodev.nvim",
      "b0o/schemastore.nvim",
      "folke/trouble.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        pyright = {},
        jdtls = {},
        bashls = {},
        html = {},
        cssls = {},
        jsonls = {},
        yamlls = {},
      }

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      -- Set up cmp_nvim_lsp for autocompletion capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      -- Setup all servers
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            settings = servers[server_name] and servers[server_name].settings or {},
            on_attach = function(client, bufnr)
              vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
              vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
              vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
              vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
              
              -- Log that the LSP attached
              vim.notify("LSP " .. client.name .. " attached to buffer", vim.log.levels.INFO)
              
              -- Force showing diagnostics
              vim.diagnostic.show()
            end,
          })
        end,
      })
      
      -- Set up diagnostic display
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 4,
          source = "if_many",
          format = function(diagnostic)
            local severity = diagnostic.severity
            local msg = diagnostic.message
            if severity == vim.diagnostic.severity.ERROR then
              return "ERROR: " .. msg
            elseif severity == vim.diagnostic.severity.WARN then
              return "WARNING: " .. msg
            elseif severity == vim.diagnostic.severity.INFO then
              return "INFO: " .. msg
            else
              return msg
            end
          end,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },
  { 
    "neovim/nvim-lspconfig",
    lazy = false,
    priority = 700,
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    }
  },
  -- Other LSP-related modules
  require("plugins.coding.lsp.cmp"),
  require("plugins.coding.lsp.treesitter")
}
