-- Keymaps for snacks.nvim features

local M = {}

M.keys = {
    {
        "<leader>e",
        function()
            local ok, explorer = pcall(require, "snacks.explorer")
            if ok then
                explorer()
            else
                vim.notify("Failed to load snacks.explorer", vim.log.levels.ERROR)
            end
        end,
        desc = "File Explorer",
    },
    {
        "<leader>tn",
        function()
            _G.show_notification_history()
        end,
        desc = "Notification History",
    },
    {
        "<leader>z",
        function()
            local ok, zen = pcall(require, "snacks.zen")
            if ok then
                zen()
            else
                vim.notify("Failed to load snacks.zen", vim.log.levels.ERROR)
            end
        end,
        desc = "Toggle Zen Mode",
    },
    {
        "<leader>n",
        function()
            _G.show_notification_history()
        end,
        desc = "Notification History",
    },
}

return M 