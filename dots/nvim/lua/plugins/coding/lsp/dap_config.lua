return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui", -- UI for DAP
		"theHamsta/nvim-dap-virtual-text", -- Display variable values inline
		"jay-babu/mason-nvim-dap.nvim", -- Integration with Mason
		"nvim-neotest/nvim-nio", -- Required by nvim-dap-ui in Neovim >= 0.10
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- Set up UI
		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸" },
			mappings = {
				-- Use a table to apply multiple mappings
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				edit = "e",
				repl = "r",
				toggle = "t",
			},
			layouts = {
				{
					elements = {
						-- Elements can be strings or table with id and size keys.
						{ id = "scopes", size = 0.25 },
						"breakpoints",
						"stacks",
						"watches",
					},
					size = 40, -- 40 columns
					position = "left",
				},
				{
					elements = {
						"repl",
						"console",
					},
					size = 0.25, -- 25% of total lines
					position = "bottom",
				},
			},
			floating = {
				max_height = nil, -- These can be integers or a float between 0 and 1.
				max_width = nil, -- Floats will be treated as percentage of your screen.
				border = "rounded", -- Border style
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			windows = { indent = 1 },
			render = {
				max_type_length = nil, -- Can be integer or nil.
				max_value_lines = 100, -- Can be integer or nil.
			},
		})

		-- Configure Java adapter
		dap.adapters.java = {
			type = "executable",
			command = "java",
			args = {
				"-jar",
				vim.fn.stdpath("data")
					.. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
			},
		}

		-- Configure Java debug configurations
		dap.configurations.java = {
			{
				type = "java",
				request = "attach",
				name = "Attach to Micro-Integrator",
				hostName = "localhost",
				port = 5000,
				projectName = vim.fn.fnamemodify(vim.fn.getcwd(), ":t"), -- Use current directory name as project
			},
			{
				type = "java",
				request = "launch",
				name = "Launch Java Program",
				mainClass = "${file}",
			},
		}

		-- Auto open/close DAP UI
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- Set up keymaps
		vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>dB", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "Conditional Breakpoint" })
		vim.keymap.set("n", "<leader>dl", dap.step_into, { desc = "Step Into" })
		vim.keymap.set("n", "<leader>dj", dap.step_over, { desc = "Step Over" })
		vim.keymap.set("n", "<leader>dk", dap.step_out, { desc = "Step Out" })
		vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
		vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
		vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle UI" })

		-- Setup virtual text
		require("nvim-dap-virtual-text").setup({
			enabled = true,
			enabled_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = false,
			show_stop_reason = true,
			commented = false,
			virt_text_pos = "eol",
			all_frames = false,
			virt_lines = false,
			virt_text_win_col = nil,
		})
	end,
}
