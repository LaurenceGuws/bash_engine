-- Telescope configuration
return {
    "nvim-telescope/telescope.nvim", 
    dependencies = { 
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons"
    },
    lazy = false, -- Important: Don't lazy load Telescope
    version = false,
    config = function()
        -- Common theme config for all pickers
        local dropdown_theme = {
            theme = "dropdown",
            previewer = false,
            layout_config = {
                width = 0.5,  -- Match theme picker width
                height = 0.5, -- Match theme picker height
            },
            borderchars = {
                prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
                results = { "─", "│", " ", "│", "├", "┤", "┘", "└" },
                preview = { "─", "│", " ", "│", "┌", "┐", "┘", "└" },
            },
        }

        -- Specific settings for pickers that need preview
        local dropdown_with_preview = {
            theme = "dropdown",
            previewer = true,
            layout_config = {
                width = 0.6,
                height = 0.6,
            },
            borderchars = {
                prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
                results = { "─", "│", " ", "│", "├", "┤", "┘", "└" },
                preview = { "─", "│", " ", "│", "┌", "┐", "┘", "└" },
            },
        }

        local telescope = require("telescope")
        
        -- Apply the dropdown theme globally
        local themes = require("telescope.themes")
        
        -- Setup Telescope with dropdown theme as default
        telescope.setup({
            defaults = vim.tbl_deep_extend("force", {
                prompt_prefix = " ",
                selection_caret = " ",
                path_display = { "smart" },
                borderchars = {
                    prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
                    results = { "─", "│", " ", "│", "├", "┤", "┘", "└" },
                    preview = { "─", "│", " ", "│", "┌", "┐", "┘", "└" },
                },
                layout_strategy = "center",
                layout_config = {
                    width = 0.5,
                    height = 0.5,
                },
                sorting_strategy = "ascending",
                file_ignore_patterns = { "node_modules" },
                mappings = {
                    i = {
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",
                        ["<C-c>"] = "close",
                    },
                },
            }, themes.get_dropdown({})),
            
            pickers = {
                -- UI controls/navigation pickers (no preview needed)
                find_files = dropdown_theme,
                buffers = dropdown_theme,
                oldfiles = dropdown_theme,
                commands = dropdown_theme,
                command_history = dropdown_theme,
                help_tags = dropdown_theme,
                keymaps = dropdown_theme,
                marks = dropdown_theme,
                registers = dropdown_theme,
                spell_suggest = dropdown_theme,
                
                -- Search-based pickers (may or may not need preview)
                live_grep = vim.tbl_extend("force", dropdown_theme, {
                    additional_args = function() return {"--hidden"} end,
                }),
                grep_string = dropdown_theme,
                current_buffer_fuzzy_find = dropdown_theme,

                -- Colorscheme picker (same as theme_ui.lua)
                colorscheme = {
                    theme = "dropdown",
                    previewer = false,
                    layout_config = {
                        width = 0.5,
                        height = 0.5,
                    },
                    borderchars = {
                        prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
                        results = { "─", "│", " ", "│", "├", "┤", "┘", "└" },
                        preview = { "─", "│", " ", "│", "┌", "┐", "┘", "└" },
                    },
                    enable_preview = true, -- This previews the theme without requiring a preview pane
                },
                
                -- Version control pickers
                git_files = dropdown_theme,
                git_commits = dropdown_with_preview,
                git_bcommits = dropdown_with_preview,
                git_status = dropdown_with_preview,
                git_branches = dropdown_theme,
                
                -- LSP pickers
                lsp_references = dropdown_with_preview,
                lsp_definitions = dropdown_with_preview,
                lsp_implementations = dropdown_with_preview,
                lsp_document_symbols = dropdown_theme,
                lsp_workspace_symbols = dropdown_theme,
                diagnostics = dropdown_with_preview,
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
            },
        })

        -- Load extensions if available
        pcall(telescope.load_extension, "fzf")
    end,
} 