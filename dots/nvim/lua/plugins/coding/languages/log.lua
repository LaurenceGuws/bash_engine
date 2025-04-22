return {
	"fei6409/log-highlight.nvim",
	event = { "BufRead", "BufNewFile" },
	ft = { "log" },
	config = function()
		require("log-highlight").setup({
			-- The file extensions
			extension = { "log", "txt" },
			
			-- The file names or the full file paths
			filename = {
				"messages",
				"syslog"
			},
			
			-- The file path glob patterns
			pattern = {
				"/var/log/.*",
				"messages%..*",
			},
		})
	end,
} 