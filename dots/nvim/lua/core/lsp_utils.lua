-- LSP utilities for enhancing the Neovim LSP experience
local M = {}

-- Format and display diagnostics in a popup and copy to clipboard
function M.show_diagnostics_popup(opts)
	opts = opts or {}
	local scope = opts.scope or "buffer" -- 'buffer' or 'workspace'

	-- Get diagnostics based on scope
	local diagnostics = {}
	local title = ""

	if scope == "buffer" then
		local bufnr = vim.api.nvim_get_current_buf()
		diagnostics = vim.diagnostic.get(bufnr)
		local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
		title = "Diagnostics for " .. filename
	else -- workspace/project scope
		-- Determine the project root
		local project_root = vim.fn.getcwd()
		title = "Project Diagnostics: " .. vim.fn.fnamemodify(project_root, ":t")

		-- Collect diagnostics from open buffers only
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
				local file_path = vim.api.nvim_buf_get_name(buf)
				if file_path and file_path ~= "" then
					local buf_diags = vim.diagnostic.get(buf)
					if #buf_diags > 0 then
						for _, diag in ipairs(buf_diags) do
							diag.file_path = vim.fn.fnamemodify(file_path, ":.")
							table.insert(diagnostics, diag)
						end
					end
				end
			end
		end
	end

	if #diagnostics == 0 then
		vim.notify("No diagnostics found.", vim.log.levels.INFO)
		return
	end

	-- Sort diagnostics by severity, then by file, then by line
	table.sort(diagnostics, function(a, b)
		-- Sort by severity (highest first)
		if a.severity ~= b.severity then
			return a.severity < b.severity
		end

		-- Then by filename if available
		if a.file_path and b.file_path and a.file_path ~= b.file_path then
			return a.file_path < b.file_path
		end

		-- Finally by line number
		return a.lnum < b.lnum
	end)

	-- Create a formatted string of diagnostics
	local lines = {}
	table.insert(lines, title .. ":")
	table.insert(lines, "")

	local current_file = nil

	for _, diagnostic in ipairs(diagnostics) do
		-- Add file header if in workspace mode and the file changes
		if scope == "workspace" and diagnostic.file_path and diagnostic.file_path ~= current_file then
			current_file = diagnostic.file_path
			if #lines > 0 and lines[#lines] ~= "" then
				table.insert(lines, "")
			end
			table.insert(lines, "File: " .. current_file)
		end

		local severity = "UNKNOWN"
		if diagnostic.severity == 1 then
			severity = "ERROR"
		elseif diagnostic.severity == 2 then
			severity = "WARN"
		elseif diagnostic.severity == 3 then
			severity = "INFO"
		elseif diagnostic.severity == 4 then
			severity = "HINT"
		end

		local line = string.format("Line %d: [%s] %s", diagnostic.lnum + 1, severity, diagnostic.message)
		table.insert(lines, line)
	end

	local output = table.concat(lines, "\n")

	-- Copy to clipboard
	vim.fn.setreg("+", output)
	vim.fn.setreg('"', output)

	-- Notify the user
	vim.notify("Diagnostics copied to clipboard", vim.log.levels.INFO)

	-- Display in a floating window
	local buf = vim.api.nvim_create_buf(false, true)

	-- Split output by lines
	local buffer_lines = {}
	for line in output:gmatch("([^\n]*)\n?") do
		table.insert(buffer_lines, line)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, buffer_lines)

	-- Set buffer options
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	-- Calculate dimensions
	local width = math.min(90, vim.o.columns - 4)
	local height = math.min(#buffer_lines + 2, vim.o.lines - 4)

	-- Calculate position
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Create a floating window
	local win_opts = {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = scope == "buffer" and "Buffer Diagnostics" or "Project Diagnostics",
		title_pos = "center",
	}

	local win = vim.api.nvim_open_win(buf, true, win_opts)

	-- Add keymaps to make the window interactive
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bdelete<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>bdelete<CR>", { noremap = true, silent = true })

	return win
end

return M
