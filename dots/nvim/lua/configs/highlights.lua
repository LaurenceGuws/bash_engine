local M = {}

M.override = {
  -- General UI Transparency
  Normal = { bg = "NONE" },
  NormalNC = { bg = "NONE" },
  EndOfBuffer = { bg = "NONE" },
  LineNr = { bg = "NONE" },
  SignColumn = { bg = "NONE" },
  Folded = { bg = "NONE" },
  NonText = { bg = "NONE" },

  --  nnn.nvim Floating Window Transparency
  NnnNormal = { bg = "NONE", fg = "#cdd6f4" },
  NnnNormalNC = { bg = "NONE", fg = "#bac2de" },
  NnnBorder = { fg = "#89b4fa" },

  --  Bufferline Transparency
  BufferLineFill = { bg = "NONE" },
  BufferLineBackground = { bg = "NONE" },

  --  Noice Command Popup Transparency
  NoiceCmdline = { bg = "NONE" },
}

function M.apply()
  for group, opts in pairs(M.override) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

return M
