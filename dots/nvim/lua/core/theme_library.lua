-- Theme Library Module
-- Centralized theme management system for Neovim
-- Inspired by Ghostty's theme management system

local M = {}

-- Debug flag for troubleshooting
local DEBUG = false

-- Function to print debug information
local function debug_print(msg)
  -- Debug output disabled
end

-- Generic function to check if a module exists
local function module_exists(name)
  return pcall(require, name)
end

-- Map of various theme repositories
-- Each repository has:
-- - variants: array of supported color variants
-- - setup(variant): function that configures the theme with the given variant
-- - get_colorscheme_name(variant): function that returns the colorscheme name for a variant
M.repositories = {
  -- Base16 Themes - A collection of over 100 themes
  ["base16"] = {
    variants = {
      -- Base16 default themes
      "default-dark", "default-light", "3024", "apathy", "ashes", "atelier-cave", 
      "atelier-dune", "atelier-estuary", "atelier-forest", "atelier-heath", 
      "atelier-lakeside", "atelier-plateau", "atelier-savanna", "atelier-seaside", 
      "atelier-sulphurpool", "atlas", "bespin", "black-metal", "brewer", "bright", 
      "brogrammer", "brush-trees", "chalk", "circus", "classic-dark", "classic-light", 
      "codeschool", "colors", "cupcake", "cupertino", "danqing", "darcula", "darkmoss", 
      "darktooth", "decaf", "default", "dirtysea", "dracula", "edge-dark", "edge-light", 
      "eighties", "embers", "equilibrium-dark", "equilibrium-gray-dark", "equilibrium-gray-light", 
      "equilibrium-light", "espresso", "eva", "eva-dim", "flat", "framer", "fruit-soda", 
      "gigavolt", "github", "google-dark", "google-light", "grayscale-dark", 
      "grayscale-light", "green-screen", "gruvbox-dark-hard", "gruvbox-dark-medium", 
      "gruvbox-dark-pale", "gruvbox-dark-soft", "gruvbox-light-hard", "gruvbox-light-medium", 
      "gruvbox-light-soft", "hardcore", "harmonic-dark", "harmonic-light", "heetch", 
      "helios", "hopscotch", "horizon", "humanoid-dark", "humanoid-light", "ia-dark", 
      "ia-light", "icy", "irblack", "isotope", "kanagawa", "macintosh", "marrakesh", 
      "materia", "material", "material-darker", "material-lighter", "material-palenight", 
      "material-vivid", "mellow-purple", "mexico-light", "mocha", "monokai", "nord", 
      "nova", "oceanicnext", "one-light", "onedark", "outrun-dark", "papercolor-dark", 
      "papercolor-light", "paraiso", "pasque", "phd", "pico", "pop", "porple", "qualia", 
      "railscasts", "rebecca", "ros-pine", "ros-pine-dawn", "ros-pine-moon", "sagelight", 
      "sandcastle", "seti", "shapeshifter", "silk-dark", "silk-light", "snazzy", 
      "solar-flare", "solarized-dark", "solarized-light", "spacemacs", "summercamp", 
      "summerfruit-dark", "summerfruit-light", "synth-midnight-dark", "tender", 
      "tomorrow", "tomorrow-night", "tomorrow-night-eighties", "tube", "twilight", 
      "unikitty-dark", "unikitty-light", "vulcan", "windows-10", "windows-10-light", 
      "windows-95", "windows-95-light", "windows-highcontrast", "windows-highcontrast-light", 
      "windows-nt", "windows-nt-light", "woodland", "xcode-dusk", "zenburn"
    },
    setup = function(variant)
      debug_print("Setting up base16 with variant: " .. (variant or "default"))
      return true
    end,
    get_colorscheme_name = function(variant)
      if not variant or variant == "" then
        variant = "tomorrow-night"
      end
      return "base16-" .. variant
    end
  },
  
  -- Nightfox Themes
  ["nightfox"] = {
    variants = { "nightfox", "dayfox", "dawnfox", "duskfox", "nordfox", "terafox", "carbonfox" },
    setup = function(variant)
      debug_print("Setting up nightfox with variant: " .. (variant or "nightfox"))
      local ok, nightfox = pcall(require, "nightfox")
      if ok then
        nightfox.setup({})
        return true
      end
      return false
    end,
    get_colorscheme_name = function(variant)
      return variant or "nightfox"
    end
  },
  
  -- Tokyo Night Themes
  ["tokyonight"] = {
    variants = { "storm", "moon", "night", "day" },
    setup = function(variant)
      debug_print("Setting up tokyonight with variant: " .. (variant or "storm"))
      local ok, tokyonight = pcall(require, "tokyonight")
      if ok then
        tokyonight.setup({ style = variant or "storm" })
        return true
      end
      return false
    end,
    get_colorscheme_name = function(variant)
      return "tokyonight" .. (variant and ("-" .. variant) or "")
    end
  },
  
  -- Catppuccin Themes
  ["catppuccin"] = {
    variants = { "mocha", "macchiato", "frappe", "latte" },
    setup = function(variant)
      debug_print("Setting up catppuccin with variant: " .. (variant or "mocha"))
      local ok, catppuccin = pcall(require, "catppuccin")
      if ok then
        catppuccin.setup({ flavour = variant or "mocha" })
        return true
      end
      return false
    end,
    get_colorscheme_name = function(variant)
      return "catppuccin" .. (variant and ("-" .. variant) or "")
    end
  },
  
  -- Material Themes
  ["material"] = {
    variants = { "darker", "lighter", "oceanic", "palenight", "deep ocean" },
    setup = function(variant)
      debug_print("Setting up material with variant: " .. (variant or "darker"))
      local ok, material = pcall(require, "material")
      if ok then
        vim.g.material_style = variant or "darker"
        material.setup()
        return true
      end
      return false
    end,
    get_colorscheme_name = function(variant)
      return "material"
    end
  },
  
  -- Gruvbox Themes
  ["gruvbox"] = {
    variants = { "dark", "light" },
    setup = function(variant)
      debug_print("Setting up gruvbox with variant: " .. (variant or "dark"))
      local ok, gruvbox = pcall(require, "gruvbox")
      if ok then
        -- Set contrast based on name
        if variant == "light" then
          vim.opt.background = "light"
        else
          vim.opt.background = "dark"
        end
        gruvbox.setup({ contrast = "hard" })
        return true
      end
      return false
    end,
    get_colorscheme_name = function(variant)
      return "gruvbox"
    end
  },

  -- OneDark Themes
  ["onedark"] = {
    variants = { "dark", "darker", "cool", "deep", "warm", "warmer" },
    setup = function(variant)
      debug_print("Setting up onedark with variant: " .. (variant or "darker"))
      local ok, onedark = pcall(require, "onedark")
      if ok then
        onedark.setup({ style = variant or "darker" })
        onedark.load() -- OneDark has its own load function
        return true
      end
      return false
    end,
    get_colorscheme_name = function(variant)
      return nil -- Return nil because we used onedark.load() which doesn't need colorscheme command
    end
  },
  
  -- Monokai Themes
  ["monokai"] = {
    variants = { "classic", "pro", "soda", "ristretto" },
    setup = function(variant)
      debug_print("Setting up monokai with variant: " .. (variant or "classic"))
      local ok, monokai = pcall(require, "monokai")
      if ok then
        -- The monokai plugin actually uses palettes, not functions for variants
        local palette_name = variant or "classic"
        -- Make sure the palette exists
        if monokai[palette_name] then
          monokai.setup({ palette = monokai[palette_name] })
          return true
        else
          -- Default to classic if variant doesn't exist
          debug_print("Monokai variant not found: " .. palette_name .. ", falling back to classic")
          monokai.setup({ palette = monokai.classic })
          return true
        end
      end
      return false
    end,
    get_colorscheme_name = function(variant)
      -- The colorscheme name is stored in the palette itself
      if variant == "soda" then
        return "monokai_soda"
      elseif variant == "pro" then
        return "monokai_pro"
      elseif variant == "ristretto" then
        return "monokai_ristretto"
      else
        return "monokai"
      end
    end
  },
  
  -- Kanagawa Themes
  ["kanagawa"] = {
    variants = { "wave", "dragon", "lotus" },
    setup = function(variant)
      debug_print("Setting up kanagawa with variant: " .. (variant or "wave"))
      local ok, kanagawa = pcall(require, "kanagawa")
      if ok then
        kanagawa.setup({ theme = variant or "wave" })
        return true
      end
      return false
    end,
    get_colorscheme_name = function(variant)
      return "kanagawa" .. (variant and "_" .. variant or "")
    end
  },
  
  -- Solarized Themes
  ["solarized"] = {
    variants = { "neo", "flat" },
    setup = function(variant)
      debug_print("Setting up solarized with variant: " .. (variant or "neo"))
      local ok, solarized = pcall(require, "solarized")
      if ok then
        solarized.setup({ theme = variant or "neo" })
        return true
      end
      return false
    end,
    get_colorscheme_name = function(variant)
      return "solarized"
    end
  }
}

-- Standalone themes without variants or with simpler setup
M.standalone_themes = {
  -- Dracula
  ["dracula"] = {
    setup = function()
      debug_print("Setting up dracula")
      return true
    end,
    get_colorscheme_name = function()
      return "dracula"
    end
  },
  
  -- Nord
  ["nord"] = {
    setup = function()
      debug_print("Setting up nord")
      return true
    end,
    get_colorscheme_name = function()
      return "nord"
    end
  },
  
  -- Everforest
  ["everforest"] = {
    setup = function()
      debug_print("Setting up everforest")
      -- Everforest has some global config options
      vim.g.everforest_background = "hard"
      return true
    end,
    get_colorscheme_name = function()
      return "everforest"
    end
  },
  
  -- Kanagawa (base only)
  ["kanagawa"] = {
    setup = function()
      debug_print("Setting up kanagawa (base)")
      local ok, kanagawa = pcall(require, "kanagawa")
      if ok then
        kanagawa.setup({})
        return true
      end
      return false
    end,
    get_colorscheme_name = function()
      return "kanagawa"
    end
  },
  
  -- GitHub Themes
  ["github"] = {
    setup = function()
      debug_print("Setting up github")
      -- Check which github theme plugin is installed
      local ok, github = pcall(require, "github-theme")
      if ok then
        github.setup({})
        return true
      else
        -- Fallback to the other common GitHub theme plugin
        local ok2 = pcall(require, "github-nvim-theme")
        if ok2 then
          require("github-nvim-theme").setup({})
          return true
        end
      end
      return false
    end,
    get_colorscheme_name = function()
      return "github_dark"
    end
  }
}

-- Get all themes from all repositories and standalone themes
function M.get_all_themes()
  local all_themes = {}
  
  -- Process repository themes with variants
  for repo_name, repo_data in pairs(M.repositories) do
    -- Check if the repository module exists
    if module_exists(repo_name) then
      -- Add base repository theme
      table.insert(all_themes, repo_name)
      
      -- Add all variants
      for _, variant in ipairs(repo_data.variants) do
        table.insert(all_themes, repo_name .. ":" .. variant)
      end
    end
  end
  
  -- Process standalone themes
  for theme_name, _ in pairs(M.standalone_themes) do
    if module_exists(theme_name) then
      table.insert(all_themes, theme_name)
    end
  end
  
  -- Sort themes alphabetically
  table.sort(all_themes)
  
  debug_print("Found " .. #all_themes .. " themes")
  return all_themes
end

-- Apply a theme
function M.apply_theme(theme_choice)
  if not theme_choice then
    return false
  end
  
  debug_print("Applying theme: " .. theme_choice)
  
  -- Parse theme choice - extract repository and variant
  local repo_name, variant = theme_choice:match("([^:]+):?(.*)")
  
  -- Function to apply a repository theme
  local function apply_repo_theme(repo_name, variant)
    local repo = M.repositories[repo_name]
    if not repo then
      vim.notify("Theme repository not found: " .. repo_name, vim.log.levels.ERROR)
      return false
    end
    
    -- Setup the theme
    local ok = repo.setup(variant ~= "" and variant or nil)
    if not ok then
      vim.notify("Failed to setup theme: " .. theme_choice, vim.log.levels.ERROR)
      return false
    end
    
    -- Get colorscheme name
    local colorscheme_name = repo.get_colorscheme_name(variant ~= "" and variant or nil)
    
    -- Apply colorscheme if needed
    if colorscheme_name then
      debug_print("Setting colorscheme: " .. colorscheme_name)
      ok, err = pcall(vim.cmd, "colorscheme " .. colorscheme_name)
      if not ok then
        vim.notify("Failed to apply colorscheme: " .. colorscheme_name .. "\n" .. (err or ""), vim.log.levels.ERROR)
        return false
      end
    else
      debug_print("No colorscheme command needed, theme was applied via API")
    end
    
    return true
  end
  
  -- Function to apply a standalone theme
  local function apply_standalone_theme(theme_name)
    local theme = M.standalone_themes[theme_name]
    if not theme then
      vim.notify("Standalone theme not found: " .. theme_name, vim.log.levels.ERROR)
      return false
    end
    
    -- Setup the theme
    local ok = theme.setup()
    if not ok then
      vim.notify("Failed to setup theme: " .. theme_name, vim.log.levels.ERROR)
      return false
    end
    
    -- Get colorscheme name
    local colorscheme_name = theme.get_colorscheme_name()
    
    -- Apply colorscheme if needed
    if colorscheme_name then
      debug_print("Setting colorscheme: " .. colorscheme_name)
      ok, err = pcall(vim.cmd, "colorscheme " .. colorscheme_name)
      if not ok then
        vim.notify("Failed to apply colorscheme: " .. colorscheme_name .. "\n" .. (err or ""), vim.log.levels.ERROR)
        return false
      end
    else
      debug_print("No colorscheme command needed, theme was applied via API")
    end
    
    return true
  end
  
  -- Check if it's a repository theme
  if M.repositories[repo_name] then
    return apply_repo_theme(repo_name, variant)
  end
  
  -- Check if it's a standalone theme
  if M.standalone_themes[repo_name] then
    return apply_standalone_theme(repo_name)
  end
  
  -- If we couldn't find the theme, try a direct colorscheme command as fallback
  debug_print("Theme not found in repositories or standalone themes, trying direct colorscheme command")
  local ok, err = pcall(vim.cmd, "colorscheme " .. repo_name)
  if not ok then
    vim.notify("Failed to apply theme: " .. theme_choice .. "\n" .. (err or ""), vim.log.levels.ERROR)
    return false
  end
  
  return true
end

-- Toggle debug mode
function M.toggle_debug()
  DEBUG = not DEBUG
  vim.notify("Theme library debug mode: " .. (DEBUG and "ON" or "OFF"), vim.log.levels.INFO)
end

return M 