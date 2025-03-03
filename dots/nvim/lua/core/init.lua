
-- Load core modules
local function load_core()
  pcall(require, "core.options")  
  pcall(require, "core.autocmds")
  pcall(require, "core.keymaps")
  pcall(require, "core.terminal")
end

load_core()

-- Load plugins through Lazy.nvim
require("lazy").setup({ import = "plugins" })
return {
  -- Export functions if we need to access them elsewhere
  load_core = load_core,
} 