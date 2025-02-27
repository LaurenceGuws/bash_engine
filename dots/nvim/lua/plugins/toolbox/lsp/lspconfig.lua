return {
  "neovim/nvim-lspconfig",
  "mfussenegger/nvim-dap",
  dependencies = { "williamboman/mason-lspconfig.nvim" },
  config = function()
    local lspconfig = require("lspconfig")
    local util = require("lspconfig.util")

    -- Define enhanced capabilities for nvim-cmp completion
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Custom on_attach function with better keymaps
    local on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true }
      local keymap = vim.api.nvim_buf_set_keymap

      keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
      keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
      keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
      keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
      keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
      keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)

      -- Enable inlay hints (if supported)
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.buf.inlay_hint(bufnr, true)
      end
    end

    -- Customize diagnostics display
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
    })

    -- List of LSP servers to install
    local servers = {
      "html", "cssls", "tsserver", "pyright", "jsonls", "yamlls",
      "dockerls", "lua_ls", "sqlls", "jdtls", "bashls", "zls"
    }

    -- Ensure LSPs are set up
    for _, lsp in ipairs(servers) do
      if lspconfig[lsp] then
        lspconfig[lsp].setup({
          on_attach = on_attach,
          capabilities = capabilities,
        })
      else
        print("Warning: LSP server '" .. lsp .. "' is not recognized.")
      end
    end

    -- 🚀 Explicitly configure `zls`
    lspconfig.zls.setup({
      autostart = true,
      on_attach = on_attach,
      capabilities = capabilities,
      cmd = { "zls" }, -- Ensure `zls` is started properly
      filetypes = { "zig", "zon" }, -- Attach to Zig & Zig Object Notation files
      root_dir = util.root_pattern("zls.json", "build.zig", ".git"), -- Find project root
      settings = {
        zls = {
          enable_autofix = true,
          enable_inlay_hints = true,
          warn_style = true,
        },
      },
    })

    -- Debugging: Check if `zls` is actually attached
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*.zig,*.zon",
      callback = function()
        local clients = vim.lsp.get_active_clients()
        local found_zls = false

        for _, client in ipairs(clients) do
          if client.name == "zls" then
            found_zls = true
          end
        end

        if not found_zls then
          print("❌ zls LSP is NOT attached to this buffer!")
        else
          print("✅ zls is running!")
        end
      end,
    })
  end,
}
