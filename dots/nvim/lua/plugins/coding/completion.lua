return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-calc",
    "kristijanhusak/vim-dadbod-completion",  -- DB completions
    "L3MON4D3/LuaSnip",                      -- Snippet engine
    "saadparwaiz1/cmp_luasnip",              -- Luasnip completion source
    "onsails/lspkind.nvim",                  -- VSCode-like pictograms
    "hrsh7th/cmp-nvim-lua",                  -- Neovim Lua API completion
    "petertriho/cmp-git",                    -- Git completions
    "windwp/nvim-autopairs",                 -- Auto-close brackets, etc.
    "rafamadriz/friendly-snippets",          -- Predefined snippets for many languages
    {
      "L3MON4D3/LuaSnip", 
      build = "make install_jsregexp", -- Required for variable transformations
      dependencies = { "rafamadriz/friendly-snippets" }
    }
  },
  config = function()
    local cmp = require("cmp")
    local lspkind = require("lspkind")
    local luasnip = require("luasnip")
    
    -- Load snippets
    require("luasnip.loaders.from_vscode").lazy_load()
    
    -- Setup autopairs integration with cmp
    local autopairs = require("nvim-autopairs")
    autopairs.setup({
      check_ts = true,  -- Use treesitter for better checking
      disable_filetype = { "TelescopePrompt" },
      fast_wrap = {
        map = "<M-e>",  -- Alt+e to fast wrap
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub(" [%'%\"%>%]%)%}%,] ", "%s+", ""),
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "Search",
        highlight_grey = "Comment"
      },
    })

    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    
    -- Get buffer source for special filetypes
    local get_buffers = function()
      local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
      if buf_ft == "sql" or buf_ft == "mysql" then
        return {
          name = "vim-dadbod-completion",
          priority = 1500  -- SQL gets top priority in SQL files
        }
      end
      return {
        name = "buffer",
        priority = 250
      }
    end
    
    -- Custom function to determine if we should auto-select the first item
    local has_words_before = function()
      if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
    end
    
    -- Better formatting for completions
    local format = lspkind.cmp_format({
      mode = "symbol_text",
      maxwidth = 50,
      ellipsis_char = "...",
      menu = {
        nvim_lsp = "[LSP]",
        nvim_lua = "[API]",
        luasnip = "[Snip]",
        buffer = "[Buf]", 
        path = "[Path]",
        calc = "[Calc]",
        cmp_git = "[Git]",
        ["vim-dadbod-completion"] = "[DB]",
      },
      before = function(entry, vim_item)
        -- Add thin space after kind icon
        vim_item.kind = string.format("%s %s", lspkind.presets.default[vim_item.kind], vim_item.kind)
        
        -- Add source
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          nvim_lua = "[Lua]",
          luasnip = "[Snip]",
          buffer = "[Buf]",
          path = "[Path]",
          calc = "[Calc]",
          cmp_git = "[Git]",
          ["vim-dadbod-completion"] = "[DB]",
        })[entry.source.name]
        
        return vim_item
      end
    })
    
    -- Setup cmp with enhanced configuration
    cmp.setup({
      completion = {
        -- Disable automatic completion popup
        autocomplete = false,
        completeopt = "menu,menuone,noselect,noinsert",
        keyword_length = 1,  -- Show completion after 1 character
      },
      
      -- Ensure items are properly preselected
      preselect = cmp.PreselectMode.Item,
      
      -- Visual customization
      window = {
        completion = {
          border = "rounded",
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
          scrollbar = true,
          col_offset = -3,
          side_padding = 1,
        },
        documentation = {
          border = "rounded",
          winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocBorder",
          scrollbar = true,
          max_height = 15,
          max_width = 80,
          -- Always show docs when available
          auto_open = true,
        },
      },
      
      -- Formatting
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = format,
      },
      
      -- Snippet configuration
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      
      -- Key mapping
      mapping = cmp.mapping.preset.insert({
        -- Custom Super-Tab functionality
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            -- Select next and ensure documentation is visible
            cmp.select_next_item({
              behavior = cmp.SelectBehavior.Select
            })
            -- Force update documentation view
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-g>u', true, true, true), 'n', true)
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            -- Pass through to insert a normal tab
            fallback()
          end
        end, { "i", "s" }),
        
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            -- Select previous and ensure documentation is visible
            cmp.select_prev_item({
              behavior = cmp.SelectBehavior.Select
            })
            -- Force update documentation view
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-g>u', true, true, true), 'n', true)
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        
        -- Special Ctrl+Space mapping for priority LSP listings
        ["<C-Space>"] = cmp.mapping(function() 
          if cmp.visible() then
            cmp.abort()
          else
            cmp.complete({
              config = {
                sources = {
                  { name = "nvim_lsp", priority = 1000 },
                  { name = "nvim_lua", priority = 900 },
                  { name = "luasnip", priority = 750 },
                  { name = "vim-dadbod-completion", priority = 700 },
                  { name = "calc", priority = 400 },
                  { name = "path", priority = 300 },
                  { name = "buffer", priority = 200 },
                }
              }
            })
          end
        end, { "i" }),
        
        -- Accept completion
        ["<CR>"] = cmp.mapping.confirm({ 
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,  -- Only confirm explicit selections
        }),
        
        -- Scroll docs
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        
        -- Cancel completion
        ["<C-e>"] = cmp.mapping.abort(),
        
        -- Trigger completion manually (if autocomplete is disabled)
        ["<C-k>"] = cmp.mapping.complete(),
        
        -- Always show documentation when navigating
        ["<C-n>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item({behavior = cmp.SelectBehavior.Select})
          else
            fallback()
          end
        end),
        ["<C-p>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item({behavior = cmp.SelectBehavior.Select})
          else
            fallback()
          end
        end),
      }),
      
      -- Sources in priority order
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "nvim_lua", priority = 900 },
        { name = "luasnip", priority = 750 },
        { name = "vim-dadbod-completion", priority = 700 },
        { name = "calc", priority = 400 },
        { name = "path", priority = 300, option = { trailing_slash = true } },
        get_buffers(),  -- Dynamic buffer source
      }),
      
      -- Experimental features
      experimental = {
        ghost_text = {
          hl_group = "CmpGhostText",
        },
      },
      
      -- Sorting configuration for more relevant completions
      sorting = {
        priority_weight = 2.0,
        comparators = {
          -- Deprioritize items containing "deprecated"
          function(entry1, entry2)
            -- Safely check if documentation exists and contains "deprecated"
            local function is_deprecated(entry)
              if not entry then return false end
              local doc = entry:get_documentation()
              if not doc then return false end
              
              -- Handle documentation potentially being a table
              if type(doc) == "table" then
                local text = doc.value or ""
                return type(text) == "string" and text:find("deprecated") ~= nil
              end
              
              -- Handle documentation being a string
              return type(doc) == "string" and doc:find("deprecated") ~= nil
            end
            
            local entry1_deprecated = is_deprecated(entry1)
            local entry2_deprecated = is_deprecated(entry2)
            
            if entry1_deprecated and not entry2_deprecated then
              return false
            elseif not entry1_deprecated and entry2_deprecated then
              return true
            else
              return nil
            end
          end,
          -- Other built-in comparators
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },
    })
    
    -- Enable completion in command mode
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
        { name = "cmdline" },
      })
    })
    
    -- Enable completion in search mode
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" }
      }
    })
    
    -- Add special handling for filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {"sql", "mysql", "plsql"},
      callback = function()
        cmp.setup.buffer({
          sources = cmp.config.sources({
            { name = "vim-dadbod-completion", priority = 1000 },
            { name = "buffer", priority = 500 },
          })
        })
      end
    })
    
    -- Git completion for commit messages
    local has_cmp_git, cmp_git = pcall(require, "cmp_git")
    if has_cmp_git then
      cmp_git.setup()
      
      -- Add git source to commit filetype
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"gitcommit", "NeogitCommitMessage"},
        callback = function()
          cmp.setup.buffer({
            sources = cmp.config.sources({
              { name = "cmp_git" },
              { name = "buffer" },
            })
          })
        end
      })
    end
    
    -- Set up custom highlighting for completion menu
    vim.api.nvim_exec([[
      highlight! link CmpItemAbbrDefault Normal
      highlight! link CmpItemAbbr Normal
      highlight! link CmpItemAbbrMatchDefault Title
      highlight! link CmpItemAbbrMatch Title
      highlight! link CmpItemAbbrMatchFuzzyDefault Title
      highlight! link CmpItemAbbrMatchFuzzy Title
      highlight! link CmpItemMenuDefault Comment
      highlight! link CmpItemMenu Comment
      highlight! PmenuSel guibg=#363a4f guifg=NONE
      highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
      highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
      highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
      highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
      highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
      highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
      highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
      highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
    ]], false)
  end,
}
