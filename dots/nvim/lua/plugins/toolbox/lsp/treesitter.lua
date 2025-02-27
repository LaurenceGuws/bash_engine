return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "vim", "lua", "html", "css", "java", "python", "dockerfile", "yaml", "json", "markdown", "sql", "markdown_inline", "latex", "zig"
    },
    highlight = { enable = true },
    auto_install = true,
    additional_vim_regex_highlighting = { "markdown" },
  },
}

