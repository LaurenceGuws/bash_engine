-- Custom tabline component
local M = {}

-- Setup tabline function and related buffer commands
function M.setup()
	-- Custom tabline function
	local function tabline()
		local s = ""

		-- Get all buffers
		local buffers = vim.api.nvim_list_bufs()
		local visible_buffers = {}

		for _, buf in ipairs(buffers) do
			if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
				table.insert(visible_buffers, buf)
			end
		end

		-- No buffers? Show empty tabline
		if #visible_buffers == 0 then
			return s
		end

		-- Loop through all buffers
		for i, buf in ipairs(visible_buffers) do
			-- Get buffer properties
			local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
			if filename == "" then
				filename = "[No Name]"
			end

			-- Format buffer name
			local bufnr = vim.api.nvim_buf_get_number(buf)

			-- Build buffer text
			local text = ""

			-- Add buffer number and highlight
			local hl_group = "TabLine"
			if buf == vim.api.nvim_get_current_buf() then
				hl_group = "TabLineSel"
				text = text .. "%#TabLineSel#"
			else
				text = text .. "%#TabLine#"
			end

			-- Add buffer content with number
			text = text .. " " .. bufnr .. ":" .. filename .. " "

			-- Add modified indicator
			if vim.bo[buf].modified then
				text = text .. "%#TabLineModified#●%#" .. hl_group .. "# "
			end

			s = s .. text
		end

		-- Set highlight group based on current buffer
		s = s .. "%#TabLineFill#"

		-- Fill the rest of the tabline
		s = s .. "%="

		-- Add right-aligned buffer count
		s = s .. "%#TabLine# " .. #visible_buffers .. " buffers "

		return s
	end

	-- Expose the tabline function globally
	_G.custom_tabline = tabline

	-- Setup the tabline
	vim.opt.showtabline = 2
	vim.opt.tabline = "%!v:lua._G.custom_tabline()"

	-- Create buffer delete command
	vim.api.nvim_create_user_command("Bdelete", function(opts)
		local bufnr = vim.fn.bufnr()
		if vim.fn.buflisted(bufnr) == 0 then
			return
		end

		-- Save buffer number for later
		local current_bufnr = bufnr

		-- If there's only one buffer, create a new one first
		if #vim.fn.getbufinfo({ buflisted = 1 }) <= 1 then
			vim.cmd("enew")
		end

		-- Go to previous buffer
		vim.cmd("bprevious")

		-- Delete the original buffer
		vim.cmd("bd! " .. current_bufnr)
	end, {})

	-- Register autocmd to refresh tabline when entering buffers
	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		callback = function()
			vim.opt.tabline = "%!v:lua._G.custom_tabline()"
		end,
	})
end

-- Buffer navigation keymaps
function M.setup_keymaps()
	vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
	vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next Buffer" })
	vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
	vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
	vim.keymap.set("n", "<leader>bc", "<cmd>Bdelete<CR>", { desc = "Close Buffer" })
end

return M
