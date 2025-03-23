-- Bufferline configuration
-- https://github.com/akinsho/bufferline.nvim
return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = "VeryLazy",
	config = function()
		require("bufferline").setup({
			options = {
				-- Use nvim's built-in LSP
				diagnostics = "nvim_lsp",
				-- Configure diagnostics display
				diagnostics_indicator = function(count, level, diagnostics_dict, context)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,
				-- Enable mouse actions
				middle_mouse_command = "bdelete! %d",
				right_mouse_command = "vertical sbuffer %d",
				-- Add buffer number for easier navigation
				numbers = function(opts)
					return string.format("%s", opts.id)
				end,
				-- Custom indicators for modified, etc.
				indicator = {
					icon = "▎", -- Custom indicator icon
					style = "icon",
				},
				-- Customize buffer separators
				separator_style = "thin", -- | "slant" | "thick" | "thin" | { 'any', 'any' },
				-- Always show tabs
				always_show_bufferline = true,
				-- Show close icon
				show_buffer_close_icons = true,
				-- Show close icon for tabs
				show_close_icon = false,
				-- Enforce regular tabs
				enforce_regular_tabs = false,
				-- Persist buffer order when switching between buffers
				persist_buffer_sort = true,
				-- Customize icons
				modified_icon = "●",
				close_icon = "",
				-- Custom highlights that adapt to colorscheme
				highlights = {
					buffer_selected = {
						bold = true,
						italic = false,
					},
					modified_selected = {
						bold = true,
						italic = false,
					},
				},
				-- Offset for file explorer (if present)
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						text_align = "center",
						separator = true,
					},
				},
			},
		})
		
		-- Key mappings
		vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous Buffer" })
		vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
		vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
		vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous Buffer" })
		vim.keymap.set("n", "<leader>bc", "<cmd>bdelete<CR>", { desc = "Close Buffer" })
		vim.keymap.set("n", "<leader>bf", "<cmd>BufferLinePick<CR>", { desc = "Pick Buffer" })
		vim.keymap.set("n", "<leader>bs", "<cmd>BufferLineSortByDirectory<CR>", { desc = "Sort by Directory" })
		vim.keymap.set("n", "<leader>b1", "<cmd>BufferLineGoToBuffer 1<CR>", { desc = "Buffer 1" })
		vim.keymap.set("n", "<leader>b2", "<cmd>BufferLineGoToBuffer 2<CR>", { desc = "Buffer 2" })
		vim.keymap.set("n", "<leader>b3", "<cmd>BufferLineGoToBuffer 3<CR>", { desc = "Buffer 3" })
		vim.keymap.set("n", "<leader>b4", "<cmd>BufferLineGoToBuffer 4<CR>", { desc = "Buffer 4" })
		vim.keymap.set("n", "<leader>b5", "<cmd>BufferLineGoToBuffer 5<CR>", { desc = "Buffer 5" })
	end,
} 