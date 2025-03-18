-- Markdown rendering plugin
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = { latex = { enabled = false } },
  config = function(_, opts)
    require("render-markdown").setup(opts)
    
    -- Create autocmd to render markdown automatically
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      pattern = { "*.md", "*.markdown" },
      callback = function()
        -- Wait a bit for the buffer to load completely
        vim.defer_fn(function()
          -- Enable Treesitter highlighting
          pcall(vim.cmd, "TSEnable highlight markdown")
          pcall(vim.cmd, "TSEnable highlight markdown_inline")
          -- Render markdown
          pcall(vim.cmd, "RenderMarkdownToggle")
        end, 100)
      end,
    })
  end,
} 