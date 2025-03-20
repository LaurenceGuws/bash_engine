local M = {}

-- Add specific FZF-Lua title/header highlight groups
local function setup_fzf_highlights()
  -- Target the specific FZF title bar that shows "grep"
  vim.api.nvim_set_hl(0, "FzfLuaHeaderBind", {})
  vim.api.nvim_set_hl(0, "FzfLuaHeaderText", {})
  vim.api.nvim_set_hl(0, "FzfLuaPreviewTitle", {})
  vim.api.nvim_set_hl(0, "FzfLuaPreviewBorder", {})
  vim.api.nvim_set_hl(0, "FzfLuaBufFlagCur", {})
  vim.api.nvim_set_hl(0, "FzfLuaBufFlagAlt", {})
  -- Add TelescopePromptTitle highlight as it may be used by fzf-lua with telescope profile
  vim.api.nvim_set_hl(0, "TelescopePromptTitle", {})
  vim.api.nvim_set_hl(0, "TelescopePreviewTitle", {})
  vim.api.nvim_set_hl(0, "TelescopeTitle", {})
  -- Try direct style overrides for the FZF header
  vim.api.nvim_set_hl(0, "fzf_hl_header", {})
  vim.api.nvim_set_hl(0, "fzf_hl_preview_header", {})
  -- The specific highlight groups for FZF-Lua's grep heading/header
  vim.api.nvim_set_hl(0, "FzfLuaFzfHeader", {})
  -- Additional highlight groups that could be used for the header
  vim.api.nvim_set_hl(0, "Comment", {})
  vim.api.nvim_set_hl(0, "Directory", {})
  vim.api.nvim_set_hl(0, "IncSearch", {})
  vim.api.nvim_set_hl(0, "Title", {})
end

-- Define custom highlight overrides (no transparency)
M.override = {
  -- Custom highlights can be defined here (without bg=NONE)
}

function M.apply()
  for group, opts in pairs(M.override) do
    vim.api.nvim_set_hl(0, group, opts)
  end
  -- Apply FZF-specific highlights
  setup_fzf_highlights()
end

return M
