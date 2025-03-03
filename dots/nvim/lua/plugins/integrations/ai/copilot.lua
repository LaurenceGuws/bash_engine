-- Custom configuration (defaults shown)
return {
  'jacob411/Ollama-Copilot',
  opts = {

    model_name = "codellama:13b",
    stream_suggestion = false,
    filetypes = {'python', 'lua','vim', "markdown", "bash"},
    ollama_model_opts = {
        num_predict = 40,
        temperature = 0.1,
    },
    keymaps = {
        suggestion = '<leader>os',
        reject = '<leader>or',
        insert_accept = '<Tab>',
    },
  }
}
