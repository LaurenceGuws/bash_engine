-- Setup and initialization logic for snacks.nvim

local M = {}

-- Initialization function that runs when the plugin loads
M.init = function()
    -- Store the original UI handlers
    local original_handlers = {
        select = vim.ui.select,
        input = vim.ui.input,
    }

    -- Load notification system
    require("plugins.ui.components.notifications").setup()
    
    -- Load tabline system
    require("plugins.ui.components.tabline").setup()
    require("plugins.ui.components.tabline").setup_keymaps()

    -- Create an autocmd to restore original UI handlers on exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            vim.ui.select = original_handlers.select
            vim.ui.input = original_handlers.input
        end,
    })

    -- Check and setup Snacks components after initialization
    vim.defer_fn(function()
        -- Get snacks if it's loaded
        local ok_snacks, snacks = pcall(require, "snacks")
        if not ok_snacks then
            return
        end

        -- We don't use the picker, but we do use the input module
        -- Don't register picker UI handler - we're using Telescope directly
        local ok_input, input = pcall(require, "snacks.input")
        if ok_input then
            vim.ui.input = input
        end

        -- Verify statusline integration
        local ok_status, _ = pcall(require, "snacks.statusline")
        if ok_status and not vim.o.statusline:match("snacks") then
            vim.notify("Statusline not containing snacks - please restart Neovim", vim.log.levels.WARN)
        end

        -- Check other important components
        pcall(require, "snacks.icons")
        pcall(require, "snacks.markdown")
    end, 100)
end

return M 