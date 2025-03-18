local M = {}

-- Add specific FZF-Lua title/header highlight groups
local function setup_fzf_highlights()
  -- Target the specific FZF title bar that shows "grep"
  vim.api.nvim_set_hl(0, "FzfLuaHeaderBind", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FzfLuaHeaderText", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FzfLuaPreviewTitle", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FzfLuaPreviewBorder", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FzfLuaBufFlagCur", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FzfLuaBufFlagAlt", { bg = "NONE" })
  -- Add TelescopePromptTitle highlight as it may be used by fzf-lua with telescope profile
  vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "TelescopeTitle", { bg = "NONE" })
  -- Try direct style overrides for the FZF header
  vim.api.nvim_set_hl(0, "fzf_hl_header", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "fzf_hl_preview_header", { bg = "NONE" })
  -- The specific highlight groups for FZF-Lua's grep heading/header
  vim.api.nvim_set_hl(0, "FzfLuaFzfHeader", { bg = "NONE" })
  -- Additional highlight groups that could be used for the header
  vim.api.nvim_set_hl(0, "Comment", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "Directory", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "IncSearch", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "Title", { bg = "NONE" })
  -- Alternative FZF header highlight syntax
  vim.cmd[[highlight FzfHeader guibg=NONE ctermbg=NONE]]
  vim.cmd[[highlight FzfLuaHeader guibg=NONE ctermbg=NONE]]
end

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
  FzfLuaFzfHeader = { bg = "NONE" },
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
  -- Apply FZF-specific highlights
  setup_fzf_highlights()
end

return M
