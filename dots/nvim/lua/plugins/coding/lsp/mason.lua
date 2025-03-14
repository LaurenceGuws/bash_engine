return {
  "williamboman/mason.nvim",
  dependencies = {
    {
      "williamboman/mason-lspconfig.nvim", -- LSP
      lazy = false,
      priority = 800,
      dependencies = {
        "folke/neodev.nvim", 
        "b0o/schemastore.nvim",
        "folke/trouble.nvim",
        "nvimtools/none-ls.nvim",
      },
    },
    "jay-babu/mason-null-ls.nvim",      -- Linters & Formatters
    "mfussenegger/nvim-dap",            -- Debug Adapter Protocol (DAP)
    "jay-babu/mason-nvim-dap.nvim",     -- Mason DAP Support
  },
  lazy = false,
  priority = 900,
  config = function()
    -- Setup Mason
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        },
        keymaps = {
          toggle_package_expand = "<CR>",
          install_package = "i",
          update_package = "u",
          check_package_version = "c",
          update_all_packages = "U",
          check_outdated_packages = "C",
          uninstall_package = "X",
          cancel_installation = "<C-c>",
        },
      },
      log_level = vim.log.levels.DEBUG,
    })
    
    -- Directly suppress health check warnings for unused languages
    do
      -- Get the health check functions with fallbacks for Neovim version differences
      local health_warn = vim.health.warn or vim.health.report_warn
      
      -- Store the original health check function
      local orig_health_warn = health_warn
      
      -- Create a pattern list of warnings to suppress
      local suppress_patterns = {
        "perl", "ruby", "node", "python2", "python3.10"
      }
      
      -- Override the warn function to filter out certain provider warnings
      vim.health.warn = function(msg, ...)
        if msg then
          for _, pattern in ipairs(suppress_patterns) do
            if msg:match(pattern) then
              -- Don't report this warning
              return
            end
          end
        end
        -- Pass through to original function for all other warnings
        orig_health_warn(msg, ...)
      end
      
      -- Ensure the report_warn alias works too
      if vim.health.report_warn then
        vim.health.report_warn = vim.health.warn
      end
    end

    -- Essential LSPs for integration development
    local mason_lspconfig = require("mason-lspconfig")
    
    -- Adding servers configuration from init.lua
    -- These server settings will be used in setup_handlers
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
      zls = {},
    }
    
    mason_lspconfig.setup({
      ensure_installed = vim.tbl_keys(servers), -- Use the servers from init.lua
      automatic_installation = true,
    })

    -- Add this configuration from init.lua
    -- Set up cmp_nvim_lsp for autocompletion capabilities
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    
    -- Setup all servers - added from init.lua
    mason_lspconfig.setup_handlers({
      function(server_name)
        require("lspconfig")[server_name].setup({
          capabilities = capabilities,
          -- Use existing settings if available
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
    
    -- Setup diagnostic display from init.lua
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

    -- Essential linters & formatters for integration code quality
    local mason_null_ls = require("mason-null-ls")
    mason_null_ls.setup({
      ensure_installed = {
        -- Formatters
        "stylua",           -- Lua formatter
        "prettier",         -- JS/TS/HTML/CSS/MD formatter
        "black",            -- Python formatter
        "isort",            -- Python import sorter
        "xmlformatter",     -- XML formatter
        "yamlfmt",          -- YAML formatter
        "jq",               -- JSON processor

        -- Linters
        "eslint_d",         -- JS/TS linter
        "flake8",           -- Python linter
        "shellcheck",       -- Shell script linter
        "hadolint",         -- Dockerfile linter
        "markdownlint",     -- Markdown linter
        "jsonlint",         -- JSON linter
        
        -- Integration-specific tools
        "spectral",         -- OpenAPI linter
        "sql-formatter",    -- SQL formatter
        "dotenv-linter",    -- .env file linter
    },
      automatic_installation = true,
      handlers = {},
    })

    -- Configure none-ls (null-ls) for additional linting/formatting
    local has_null_ls, null_ls = pcall(require, "none-ls")
    if not has_null_ls then
      vim.notify("none-ls not found, linting and formatting may be limited", vim.log.levels.WARN)
      return
    end
    
    null_ls.setup({
      sources = {
        -- Code Actions
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.code_actions.eslint_d,
        
        -- Completion
        null_ls.builtins.completion.spell,
        
        -- Diagnostics (many added for integration work)
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.diagnostics.jsonlint,
        null_ls.builtins.diagnostics.markdownlint,
        null_ls.builtins.diagnostics.shellcheck,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.diagnostics.hadolint,   -- Docker
        null_ls.builtins.diagnostics.spectral,   -- OpenAPI linting
        null_ls.builtins.diagnostics.dotenv_linter,
        
        -- Formatting
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.formatting.prettier.with({
          extra_filetypes = { "json", "yaml", "markdown", "graphql" }
        }),
        null_ls.builtins.formatting.sql_formatter,
        null_ls.builtins.formatting.jq,
        null_ls.builtins.formatting.xmlformat,
      },
      -- Automatically format on save
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          -- Format on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              -- Only format if explicitly enabled for this buffer
              if vim.b.format_on_save then
                vim.lsp.buf.format({ async = false })
              end
            end,
          })
          
          -- Create command to toggle format on save
          vim.api.nvim_buf_create_user_command(bufnr, "ToggleFormatOnSave", function()
            vim.b.format_on_save = not vim.b.format_on_save
            print("Format on save " .. (vim.b.format_on_save and "enabled" or "disabled"))
          end, { desc = "Toggle format on save" })
        end
      end,
    })

    -- Enable format on save by default for certain filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "lua", "python", "javascript", "typescript", "json", "html", "css", "yaml" },
      callback = function()
        vim.b.format_on_save = true
      end,
    })

    -- Manually install only useful DAPs
    local mason_dap = require("mason-nvim-dap")
    mason_dap.setup({
      ensure_installed = {
        "python",   -- Python Debugging
        "delve",    -- Go Debugging
        "cppdbg",   -- C++ Debugging
        "java-debug-adapter", -- Java Debugging
        "js-debug-adapter", -- JavaScript/TypeScript Debugging
      },
      automatic_installation = true,
      handlers = {
        function(config)
          -- All sources with no handler get passed here
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    })
  end,
}

