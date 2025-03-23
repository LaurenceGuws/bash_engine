-- Configuration options for snacks.nvim

return {
    bigfile = { enabled = true },
    dashboard = { 
        enabled = true,
        -- Custom dashboard configuration with simplified sections
        sections = {
            { section = "header" },
            { section = "keys", padding = 1 },
        },
        preset = {
            -- ASCII art placeholder - replace with your own art
            header = [[
░█▀█░█▀▀░█▀█░█░█░▀█▀░█▄█
░█░█░█▀▀░█░█░▀▄▀░░█░░█░█
░▀░▀░▀▀▀░▀▀▀░░▀░░▀▀▀░▀░▀
]],
            -- Combined keys with all functionality
            keys = {
                -- Files
                { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
                { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
                { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
                { icon = " ", key = "b", desc = "Buffers", action = ":Telescope buffers" },
                
                -- Tools
                { icon = "󰒲 ", key = "p", desc = "Plugins", action = ":Lazy" },
                { icon = " ", key = "m", desc = "Mason", action = ":Mason" },
                { icon = " ", key = "t", desc = "Terminal", action = ":lua require('snacks.terminal').toggle()" },
                { icon = " ", key = "c", desc = "Config", action = ":Telescope find_files cwd=" .. vim.fn.stdpath('config') },
                
                -- Exit
                { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
        },
    },
    explorer = { 
        enabled = true,
        replace_netrw = true, -- Replace netrw with snacks explorer
    },
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
        enabled = true, -- We need to enable picker for explorer
        override_ui = false,
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = {
        enabled = true,
        -- Terminal configuration options
        win = { 
            style = "terminal",
            border = "rounded", 
        },
        shell = vim.o.shell, -- Use the default shell
    },
    toggle = { 
        enabled = true,
        notify = true,
        which_key = true,
    },
    words = { enabled = true },
    styles = {
        notification = {
            -- wo = { wrap = true }
        },
        terminal = {
            bo = {
                filetype = "snacks_terminal",
            },
            wo = {},
            keys = {
                q = "hide",
                -- Double escape to get to normal mode
                term_normal = {
                    "<esc>",
                    function(self)
                        self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
                        if self.esc_timer:is_active() then
                            self.esc_timer:stop()
                            vim.cmd("stopinsert")
                        else
                            self.esc_timer:start(200, 0, function() end)
                            return "<esc>"
                        end
                    end,
                    mode = "t",
                    expr = true,
                    desc = "Double escape to normal mode",
                },
            },
        },
    },
} 