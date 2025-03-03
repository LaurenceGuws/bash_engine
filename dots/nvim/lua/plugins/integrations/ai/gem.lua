return {
  "David-Kunz/gen.nvim",
  lazy = false, -- Load the plugin during startup
  config = function()
    require("gen").setup({
      model = "codellama:13b", -- Default model
      quit_map = "q", -- Keymap to close the response window
      retry_map = "<c-r>", -- Keymap to re-send the current prompt
      accept_map = "<c-cr>", -- Keymap to replace the previous selection with the last result
      host = "localhost", -- Host running the Ollama service
      port = "11434", -- Port for the Ollama service
      display_mode = "float", -- Display mode: "float", "split", or "horizontal-split"
      show_prompt = true, -- Show the prompt submitted to Ollama
      show_model = true, -- Display the model at the beginning of the chat session
      no_auto_close = true, -- Prevent automatic closing of the window
      file = true, -- Write the payload to a temporary file to shorten the command
      hidden = false, -- Hide the generation window (requires Neovim >= 0.10)
      init = function(options)
        pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
      end,
      command = function(options)
        local body = { model = options.model, stream = true }
        return "curl --silent --no-buffer -X POST http://" .. options.host .. ":" .. options.port .. "/api/chat -d $body"
      end,
      result_filetype = "markdown", -- Filetype for the result buffer
      debug = false, -- Enable debug mode to print errors and commands
    })
  end,
}

