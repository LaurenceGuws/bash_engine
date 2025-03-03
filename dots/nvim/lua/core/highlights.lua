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
  VertSplit = { bg = "NONE" },
  
  -- Floating Windows & Popups
  NormalFloat = { bg = "NONE" },
  FloatBorder = { bg = "NONE" },
  FloatTitle = { bg = "NONE" },
  Pmenu = { bg = "NONE" },
  PmenuSel = { bg = "NONE" },
  PmenuSbar = { bg = "NONE" },
  PmenuThumb = { bg = "NONE" },
  
  -- Completion Menu
  CmpNormal = { bg = "NONE" },
  CmpBorder = { bg = "NONE" },
  CmpDocNormal = { bg = "NONE" },
  CmpDocBorder = { bg = "NONE" },
  
  -- WhichKey
  WhichKeyFloat = { bg = "NONE" },
  WhichKeyBorder = { bg = "NONE" },
  
  --  Bufferline Transparency
  BufferLineFill = { bg = "NONE" },
  BufferLineBackground = { bg = "NONE" },

  --  Noice Command Popup Transparency
  NoiceCmdline = { bg = "NONE" },
  NoiceCmdlinePopup = { bg = "NONE" },
  NoicePopup = { bg = "NONE" },
  NoicePopupBorder = { bg = "NONE" },
  
  -- Notifications
  NotifyBackground = { bg = "NONE" },
  
  -- FZF-Lua Fuzzy Finder
  FzfLuaNormal = { bg = "NONE" },
  FzfLuaBorder = { bg = "NONE" },
  FzfLuaCursor = { bg = "NONE" },
  FzfLuaCursorLine = { bg = "NONE" },
  FzfLuaCursorLineNr = { bg = "NONE" },
  FzfLuaSearch = { bg = "NONE" },
  FzfLuaTitle = { bg = "NONE" },
  FzfLuaScrollFloatEmpty = { bg = "NONE" },
  
  -- Override standard highlight groups used by plugins
  Search = { bg = "NONE" },
  IncSearch = { bg = "NONE" },
  CursorLine = { bg = "NONE" },
  StatusLine = { bg = "NONE" },
  StatusLineNC = { bg = "NONE" },
  WildMenu = { bg = "NONE" },
  Cursor = { bg = "NONE" },
  lCursor = { bg = "NONE" },
  Title = { bg = "NONE" },
  
  -- Other UI Elements
  TelescopeNormal = { bg = "NONE" },
  TelescopeBorder = { bg = "NONE" },
  TelescopePromptNormal = { bg = "NONE" },
  TelescopePromptBorder = { bg = "NONE" },
  TelescopeResultsNormal = { bg = "NONE" },
  TelescopeResultsBorder = { bg = "NONE" },
  TelescopePreviewNormal = { bg = "NONE" },
  TelescopePreviewBorder = { bg = "NONE" },
  
  -- LSP UI
  LspFloatWinNormal = { bg = "NONE" },
  LspFloatWinBorder = { bg = "NONE" },
  DiagnosticFloat = { bg = "NONE" },
}

function M.apply()
  for group, opts in pairs(M.override) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

return M
