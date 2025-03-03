return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "vim", "lua", "html", "css", "java", "python", "dockerfile", "yaml", "json", "markdown", "sql", "markdown_inline", "latex", "zig", "regex", "bash"
    },
    highlight = { 
      enable = true,
      additional_vim_regex_highlighting = { "markdown" },
    },
    auto_install = true,
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
    
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {"markdown", "md"},
      callback = function()
        vim.cmd("TSEnable highlight markdown")
        vim.cmd("TSEnable highlight markdown_inline")
      end
    })
  end,
}

