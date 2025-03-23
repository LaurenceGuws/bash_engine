-- Configuration options for snacks.nvim

return {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { enabled = true },
    image = { enabled = true },
    indent = { enabled = true },
    input = {
        enabled = true,
        override_ui = true,
    },
    notifier = {
        enabled = false, -- Disable the notifier but in a way that can still be indexed
        timeout = 0,
        popups = false,
    },
    picker = {
        enabled = false, -- Disabled - using our Telescope setup instead
        override_ui = false,
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
        notification = {
            -- wo = { wrap = true }
        },
    },
} 