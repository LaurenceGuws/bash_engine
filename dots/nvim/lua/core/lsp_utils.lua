-- LSP utilities for enhancing the Neovim LSP experience
local M = {}

-- Finds all files in a directory recursively that match a pattern
local function find_files(directory, pattern, ignore_patterns)
	ignore_patterns = ignore_patterns
		or {
			"%.git/",
			"node_modules/",
			"%.cache/",
			"%.npm/",
			"vendor/",
			"%.idea/",
			"%.vscode/",
			"%.DS_Store",
		}

	local handle = vim.loop.fs_scandir(directory)
	if not handle then
		return {}
	end

	local files = {}

	while true do
		local name, type = vim.loop.fs_scandir_next(handle)
		if not name then
			break
		end

		local path = directory .. "/" .. name

		-- Check if path should be ignored
		local ignore = false
		for _, ignore_pattern in ipairs(ignore_patterns) do
			if path:match(ignore_pattern) then
				ignore = true
				break
			end
		end

		if not ignore then
			if type == "directory" then
				local sub_files = find_files(path, pattern, ignore_patterns)
				for _, file in ipairs(sub_files) do
					table.insert(files, file)
				end
			elseif type == "file" then
				if not pattern or path:match(pattern) then
					table.insert(files, path)
				end
			end
		end
	end

	return files
end

-- Get the file extension from a path
local function get_file_extension(path)
	return path:match("%.([^.]+)$")
end

-- Map common extensions to filetypes
local extension_to_ft = {
	-- Basic languages
	js = "javascript",
	jsx = "javascriptreact",
	ts = "typescript",
	tsx = "typescriptreact",
	py = "python",
	rb = "ruby",
	go = "go",
	rs = "rust",
	lua = "lua",
	c = "c",
	cpp = "cpp",
	h = "c",
	hpp = "cpp",
	java = "java",
	php = "php",
	cs = "cs",
	html = "html",
	css = "css",
	scss = "scss",
	json = "json",
	md = "markdown",
	yaml = "yaml",
	yml = "yaml",
	toml = "toml",
	sh = "sh",
	bash = "bash",
	zsh = "zsh",
	vim = "vim",
	tex = "tex",
	sql = "sql",

	-- Additional languages
	tf = "terraform",
	tfvars = "terraform",
	hcl = "terraform",
	txt = "text",
	text = "text",
	thrift = "thrift",
	twig = "twig",
	typespec = "typespec",
	typst = "typst",
	v = "v",
	vhdl = "vhdl",
	vl = "verilog",
	sv = "verilog",
	vala = "vala",
	vapi = "vala",
	wgsl = "wgsl",
	xml = "xml",
	yara = "yara",
	zeek = "zeek",
	zig = "zig",
	bazelrc = "bazelrc",
	http = "http",
	rest = "http",
	rst = "rst",
	vue = "vue",

	-- Ensure common config files are recognized
	dockerignore = "dockerignore",
	dockerfile = "dockerfile",
	eslintrc = "json",
	gitignore = "gitignore",
	prisma = "prisma",
	svelte = "svelte",
	graphql = "graphql",
	gql = "graphql",
	proto = "proto",
	astro = "astro",
	kt = "kotlin",
	kts = "kotlin",
	dart = "dart",
	elm = "elm",
	ex = "elixir",
	exs = "elixir",
	erl = "erlang",
	fs = "fsharp",
	fsi = "fsharp",
	fsx = "fsharp",
	groovy = "groovy",
	hs = "haskell",
	lhs = "haskell",
	jl = "julia",
	lisp = "lisp",
	cl = "lisp",
	nim = "nim",
	nims = "nim",
	objc = "objc",
	m = "objc",
	mm = "objcpp",
	pl = "perl",
	pm = "perl",
	pp = "puppet",
	r = "r",
	rmd = "rmd",
	swift = "swift",
}

-- Check if a file has a specific LSP server attached
local function has_lsp_for_filetype(extension)
	local ft = extension_to_ft[extension]
	if not ft then
		return false
	end

	-- Check if there are LSP clients for this filetype
	local clients = vim.lsp.get_active_clients()
	for _, client in ipairs(clients) do
		if client.config and client.config.filetypes then
			for _, filetype in ipairs(client.config.filetypes) do
				if filetype == ft then
					return true
				end
			end
		end
	end

	return false
end

-- Format and display diagnostics in a popup and copy to clipboard
function M.show_diagnostics_popup(opts)
	opts = opts or {}
	local scope = opts.scope or "buffer" -- 'buffer' or 'workspace'
	local headless = opts.headless or false
	local output_file = opts.output_file
	local output_format = opts.output_format or "text" -- "text", "json", "markdown"
	local aggressive = opts.aggressive or false

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

		-- First collect all existing diagnostics from current buffers
		vim.notify("Collecting diagnostics from open files...", vim.log.levels.INFO)
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

		-- If aggressive scanning is requested
		if aggressive then
			vim.notify("Scanning project files (this may take a while)...", vim.log.levels.INFO)

			-- Check Lua files with luacheck
			local lua_files = find_files(project_root, "%.lua$")
			if #lua_files > 0 then
				vim.notify("Checking " .. #lua_files .. " Lua files with luacheck...", vim.log.levels.INFO)

				-- Try different approaches for Lua files
				local found_lua_issues = false

				-- First try with luacheck if available
				if vim.fn.executable("luacheck") == 1 then
					-- Create a temporary file with the list of Lua files
					local temp_file = os.tmpname()
					local file = io.open(temp_file, "w")
					if file then
						for _, lua_file in ipairs(lua_files) do
							file:write(lua_file .. "\n")
						end
						file:close()

						-- Run luacheck with more aggressive options
						local cmd = string.format(
							"luacheck --no-color --formatter plain --codes --max-line-length=120 --files-from=%s",
							temp_file
						)
						vim.notify("Running: " .. cmd, vim.log.levels.DEBUG)

						local handle = io.popen(cmd .. " 2>&1", "r")
						if handle then
							local luacheck_output = handle:read("*a")
							local exit_code = handle:close()

							vim.notify(
								"Luacheck complete with "
									.. (exit_code and "exit code " .. tostring(exit_code) or "unknown exit code"),
								vim.log.levels.DEBUG
							)

							-- Check if output has actual diagnostics
							if luacheck_output and luacheck_output:match("%d+:%d+:") then
								-- Parse luacheck output and convert to diagnostics
								for line in luacheck_output:gmatch("[^\r\n]+") do
									-- Example line: path/to/file.lua:10:5: (W211) unused variable 'foo'
									local file_path, line_num, col, code, message =
										line:match("(.+):(%d+):(%d+): %(([%w_]+)%) (.+)")
									if file_path and line_num and message then
										local severity = 2 -- default to warning
										if code:sub(1, 1) == "E" then
											severity = 1 -- error
										elseif code:sub(1, 1) == "W" then
											severity = 2 -- warning
										else
											severity = 3 -- info
										end

										table.insert(diagnostics, {
											file_path = vim.fn.fnamemodify(file_path, ":."),
											lnum = tonumber(line_num) - 1,
											col = tonumber(col) - 1,
											message = message .. " (" .. code .. ")",
											severity = severity,
										})
										found_lua_issues = true
									end
								end
							end
						end

						-- Remove temporary file
						os.remove(temp_file)
					end
				end

				-- If no Lua issues found with luacheck, try using stylua
				if not found_lua_issues and vim.fn.executable("stylua") == 1 then
					vim.notify("Checking with stylua for style issues...", vim.log.levels.INFO)

					for _, lua_file in ipairs(lua_files) do
						-- Run stylua with --check mode
						local cmd = string.format("stylua --check --verify %s", vim.fn.shellescape(lua_file))
						local handle = io.popen(cmd .. " 2>&1", "r")

						if handle then
							local stylua_output = handle:read("*a")
							handle:close()

							-- Check if stylua found formatting issues
							if stylua_output and stylua_output:match("Error") then
								table.insert(diagnostics, {
									file_path = vim.fn.fnamemodify(lua_file, ":."),
									lnum = 0,
									col = 0,
									message = "Formatting doesn't match stylua style (use stylua to fix)",
									severity = 3, -- info
								})
								found_lua_issues = true
							end
						end
					end
				end

				-- If still no issues found, fall back to basic checks
				if not found_lua_issues then
					vim.notify("Falling back to basic style checks...", vim.log.levels.INFO)
					for _, file in ipairs(lua_files) do
						-- Read file content
						local file_handle = io.open(file, "r")
						if file_handle then
							local line_num = 0
							for line in file_handle:lines() do
								line_num = line_num + 1
								-- Simple checks that don't require LSP
								if line:match("^%s+$") then
									table.insert(diagnostics, {
										file_path = vim.fn.fnamemodify(file, ":."),
										lnum = line_num - 1,
										col = 0,
										message = "Line with spaces only",
										severity = 3, -- hint
									})
									found_lua_issues = true
								elseif line:match("%s+$") then
									table.insert(diagnostics, {
										file_path = vim.fn.fnamemodify(file, ":."),
										lnum = line_num - 1,
										col = 0,
										message = "Line with trailing space",
										severity = 3, -- hint
									})
									found_lua_issues = true
								end
							end
							file_handle:close()
						end
					end
				end
			end

			-- Add other language checks based on formatters you have installed

			-- Check JavaScript/TypeScript files with prettier if available
			if vim.fn.executable("prettier") == 1 then
				local js_files = find_files(project_root, "%.[jt]sx?$")
				if #js_files > 0 then
					vim.notify("Checking " .. #js_files .. " JS/TS files with prettier...", vim.log.levels.INFO)

					for _, js_file in ipairs(js_files) do
						-- Run prettier with --check mode
						local cmd = string.format("prettier --check %s", vim.fn.shellescape(js_file))
						local handle = io.popen(cmd .. " 2>&1", "r")

						if handle then
							local prettier_output = handle:read("*a")
							handle:close()

							-- Check if prettier found formatting issues
							if prettier_output and prettier_output:match("[Cc]ode style issues") then
								table.insert(diagnostics, {
									file_path = vim.fn.fnamemodify(js_file, ":."),
									lnum = 0,
									col = 0,
									message = "Formatting doesn't match prettier style (use prettier to fix)",
									severity = 3, -- info
								})
							end
						end
					end
				end
			end

			-- Check Python files with black and isort if available
			if vim.fn.executable("black") == 1 or vim.fn.executable("isort") == 1 then
				local py_files = find_files(project_root, "%.py$")
				if #py_files > 0 then
					vim.notify("Checking " .. #py_files .. " Python files...", vim.log.levels.INFO)

					for _, py_file in ipairs(py_files) do
						-- Check with black if available
						if vim.fn.executable("black") == 1 then
							local cmd = string.format("black --check %s", vim.fn.shellescape(py_file))
							local handle = io.popen(cmd .. " 2>&1", "r")

							if handle then
								local black_output = handle:read("*a")
								handle:close()

								-- Check if black found formatting issues
								if black_output and black_output:match("would reformat") then
									table.insert(diagnostics, {
										file_path = vim.fn.fnamemodify(py_file, ":."),
										lnum = 0,
										col = 0,
										message = "Formatting doesn't match black style (use black to fix)",
										severity = 3, -- info
									})
								end
							end
						end

						-- Check with isort if available
						if vim.fn.executable("isort") == 1 then
							local cmd = string.format("isort --check-only %s", vim.fn.shellescape(py_file))
							local handle = io.popen(cmd .. " 2>&1", "r")

							if handle then
								local isort_output = handle:read("*a")
								handle:close()

								-- Check if isort found import ordering issues
								if isort_output and isort_output:match("would reformat") then
									table.insert(diagnostics, {
										file_path = vim.fn.fnamemodify(py_file, ":."),
										lnum = 0,
										col = 0,
										message = "Import order needs fixing (use isort to fix)",
										severity = 3, -- info
									})
								end
							end
						end
					end
				end
			end

			-- Check shell scripts with shfmt if available
			if vim.fn.executable("shfmt") == 1 then
				local sh_files = find_files(project_root, "%.[bz]?sh$")
				if #sh_files > 0 then
					vim.notify("Checking " .. #sh_files .. " shell scripts with shfmt...", vim.log.levels.INFO)

					for _, sh_file in ipairs(sh_files) do
						-- Run shfmt with diff mode
						local cmd = string.format("shfmt -d %s", vim.fn.shellescape(sh_file))
						local handle = io.popen(cmd .. " 2>&1", "r")

						if handle then
							local shfmt_output = handle:read("*a")
							handle:close()

							-- Check if shfmt found formatting issues
							if shfmt_output and shfmt_output ~= "" then
								table.insert(diagnostics, {
									file_path = vim.fn.fnamemodify(sh_file, ":."),
									lnum = 0,
									col = 0,
									message = "Shell script formatting issues detected (use shfmt to fix)",
									severity = 3, -- info
								})
							end
						end
					end
				end
			end
		end
	end

	if #diagnostics == 0 then
		vim.notify(
			"No diagnostics found. Your code looks clean or try opening some files to activate LSP.",
			vim.log.levels.INFO
		)
		return
	end

	-- Sort diagnostics by severity, then by file (for workspace), then by line
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

	-- Format the diagnostics based on output format
	local output = ""

	if output_format == "json" then
		-- Convert to JSON format
		local json_data = {}
		for _, diag in ipairs(diagnostics) do
			local severity = vim.diagnostic.severity[diag.severity] or "UNKNOWN"
			table.insert(json_data, {
				file = diag.file_path or "",
				line = diag.lnum + 1,
				col = diag.col or 0,
				severity = severity,
				message = diag.message,
			})
		end
		output = vim.fn.json_encode(json_data)
	elseif output_format == "markdown" then
		-- Convert to Markdown format
		local md_lines = {}
		table.insert(md_lines, "# " .. title)
		table.insert(md_lines, "")

		local current_file = nil

		for _, diag in ipairs(diagnostics) do
			if scope == "workspace" and diag.file_path and diag.file_path ~= current_file then
				current_file = diag.file_path
				table.insert(md_lines, "## File: " .. current_file)
				table.insert(md_lines, "")
			end

			local severity = vim.diagnostic.severity[diag.severity] or "UNKNOWN"
			local line = string.format("- **Line %d:** _%s_ - %s", diag.lnum + 1, severity, diag.message)
			table.insert(md_lines, line)
		end

		output = table.concat(md_lines, "\n")
	else -- text format (default)
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

		output = table.concat(lines, "\n")
	end

	-- Handle output based on mode
	if headless then
		if output_file then
			-- Write to file
			local file = io.open(output_file, "w")
			if file then
				file:write(output)
				file:close()
				print("Diagnostics written to " .. output_file)
			else
				print("Error: Could not write to file " .. output_file)
			end
		else
			-- Print to stdout
			print(output)
		end
		return
	end

	-- Interactive mode continues here...

	-- Copy to clipboard
	vim.fn.setreg("+", output)
	vim.fn.setreg('"', output)

	-- Notify the user
	vim.notify("Diagnostics copied to clipboard", vim.log.levels.INFO)

	-- Also display in a temporary buffer
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

	-- Add ability to jump to diagnostic location on Enter
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<CR>",
		[[<cmd>lua require("core.lsp_utils").jump_to_diagnostic_from_list()<CR>]],
		{ noremap = true, silent = true }
	)

	-- Store diagnostic information in buffer variable for later use
	vim.api.nvim_buf_set_var(buf, "diagnostics_list", diagnostics)

	return win
end

-- Helper function to jump to a diagnostic from the list
function M.jump_to_diagnostic_from_list()
	local buf = vim.api.nvim_get_current_buf()

	-- Get the diagnostics list associated with this buffer
	local ok, diagnostics = pcall(vim.api.nvim_buf_get_var, buf, "diagnostics_list")
	if not ok or not diagnostics then
		vim.notify("Diagnostic information not found", vim.log.levels.ERROR)
		return
	end

	-- Get current line in the buffer
	local line = vim.api.nvim_win_get_cursor(0)[1]

	-- Find the diagnostic associated with this line
	local selected_diag = nil
	local current_file = nil
	local file_start_line = 0
	local diag_index = 0

	-- Skip header lines
	if line <= 2 then
		return
	end

	-- Parse the buffer to find the diagnostic at the current line
	for i, buf_line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		if i >= line then
			break
		end

		if buf_line:match("^File: ") then
			current_file = buf_line:gsub("^File: ", "")
			file_start_line = i
		elseif buf_line:match("^Line %d+: %[") and current_file then
			diag_index = diag_index + 1
			if i == line then
				-- This is the line the cursor is on
				selected_diag = diagnostics[diag_index]
				break
			end
		end
	end

	-- If no diagnostic found directly, try to find by proximity
	if not selected_diag then
		for _, diag in ipairs(diagnostics) do
			if diag.file_path == current_file then
				selected_diag = diag
				break
			end
		end
	end

	-- Jump to the diagnostic location
	if selected_diag then
		if selected_diag.file_path then
			-- Open the file if it's not already open
			vim.cmd("edit " .. selected_diag.file_path)
		end

		-- Jump to the line
		if selected_diag.lnum then
			vim.api.nvim_win_set_cursor(0, { selected_diag.lnum + 1, selected_diag.col or 0 })
			vim.cmd("normal! zz") -- Center the cursor
		end

		-- Close the diagnostics window
		vim.cmd("bdelete " .. buf)
	end
end

-- Run headless linting for CI/command line usage
function M.headless_lint(opts)
	opts = opts or {}
	opts.headless = true
	opts.scope = "workspace"

	-- Set output format and file
	opts.output_format = opts.output_format or "text"

	-- Run the diagnostics function in headless mode
	M.show_diagnostics_popup(opts)
end

-- Function to lint project and save results to a file
function M.lint_project_to_file(output_file, format)
	format = format or "text"
	M.headless_lint({
		output_file = output_file,
		output_format = format,
	})
end

return M
