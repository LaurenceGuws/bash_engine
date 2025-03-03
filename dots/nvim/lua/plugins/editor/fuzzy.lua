return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  keys = {
    { "<leader>fbb", "<cmd>FzfLua buffers<CR>", desc = "Buffers (FZF)" },
    { "<leader>fgg", "<cmd>FzfLua live_grep<CR>", desc = "Live Grep (FZF)" },
    { "<leader>fgw", "<cmd>FzfLua grep_cword<CR>", desc = "Grep Current Word (FZF)" },
    { "<leader>fh", "<cmd>FzfLua help_tags<CR>", desc = "Help Tags (FZF)" },
    { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent Files (FZF)" },
    { "<leader>fm", "<cmd>FzfLua marks<CR>", desc = "Marks (FZF)" },
  },
  opts = {
    "telescope",
    winopts = {
      height = 0.85,
      width = 0.80,
      preview = {
        default = "bat",
        vertical = "up:60%",
        horizontal = "right:60%",
        layout = "flex",
        title = true,
        scrollbar = "float",
        scrolloff = "-2",
        scrollchars = { "█", "" },
      },
    },
    keymap = {
      builtin = {
        ["<C-d>"] = "preview-page-down",
        ["<C-u>"] = "preview-page-up",
      },
    },
    fzf_opts = {
      ["--layout"] = "reverse",
    },
    previewers = {
      -- Configure media previewer to use installed tools
      -- Since chafa is installed, it will be used by default
      image = {
        enabled = true,
        -- Try using chafa first, which we know is installed
        render_method = "chafa", -- default to chafa since it's installed
      },
    },
  },
  config = function(_, opts)
    require("fzf-lua").setup(opts)
    
    -- Display notification about optional tools
    vim.defer_fn(function()
      local missing_tools = {}
      
      -- Check for viu
      if vim.fn.executable("viu") == 0 then
        table.insert(missing_tools, "viu")
      end
      
      -- Check for ueberzugpp
      if vim.fn.executable("ueberzugpp") == 0 then
        table.insert(missing_tools, "ueberzugpp")
      end
      
      if #missing_tools > 0 and vim.fn.executable("chafa") == 1 then
        vim.notify(
          "FZF-Lua is using chafa for image previews. For enhanced preview capabilities, consider installing: " 
          .. table.concat(missing_tools, ", "),
          vim.log.levels.INFO,
          { title = "FZF-Lua Media Previews" }
        )
      end
    end, 3000)
  end,
} 