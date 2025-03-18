return {
  "folke/noice.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  event = "VeryLazy",
  config = function()
    require("noice").setup({
      presets = {
        command_palette = true,  -- Keep enhanced command UI
        lsp_doc_border = true,   -- Keep borders around LSP popups
      },
      cmdline = {
        view = "cmdline_popup",
        format = {
          cmdline = { icon = "" },
          search_down = { icon = "🔍⌄" },
          search_up = { icon = "🔍⌃" },
          filter = { icon = "🌐" },
          lua = { icon = "" },
        },
      },
      messages = { enabled = true },
      popupmenu = { enabled = true },
      lsp = {
        progress = { enabled = false },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
    })

    -- Set Noice as the handler for LSP popups
    vim.lsp.handlers["textDocument/hover"] = require("noice").hover
    vim.lsp.handlers["textDocument/signatureHelp"] = require("noice").signature

    -- Remove the custom vim.notify override as it might interfere with diagnostics
    -- Let the notification system from nvim-notify handle this instead
  end,
}
