return {
  {
    "ramilito/kubectl.nvim",
    config = function()
      require("kubectl").setup()

      -- Keybinding for toggling kubectl
      vim.keymap.set("n", "<leader>tkl", '<cmd>lua require("kubectl").toggle()<cr>', { noremap = true, silent = true, desc = "Kube lua" })
    end,
    lazy = false,
    opts = {
      log_level = vim.log.levels.INFO,
      auto_refresh = {
        enabled = true,
        interval = 300, -- milliseconds
      },
      diff = {
        bin = "kubediff", -- or any other binary
      },
      kubectl_cmd = { cmd = "kubectl", env = {}, args = {}, persist_context_change = false },
      terminal_cmd = nil, -- Exec will launch in a terminal if set, i.e. "ghostty -e"
      namespace = "All",
      namespace_fallback = {}, -- If you have limited access, list all namespaces here
      hints = true,
      context = true,
      heartbeat = true,
      lineage = {
        enabled = false, -- This feature is in beta at the moment
      },
      logs = {
        prefix = true,
        timestamps = true,
        since = "5m",
      },
      alias = {
        apply_on_select_from_history = true,
        max_history = 5,
      },
      filter = {
        apply_on_select_from_history = true,
        max_history = 10,
      },
      float_size = {
        width = 0.9,
        height = 0.8,
        col = 10,
        row = 5,
      },
      obj_fresh = 5, -- Highlight if creation newer than number (in minutes)
      skew = {
        enabled = true,
        log_level = vim.log.levels.INFO, -- Missing comma fixed
      },
    },
  },
}

