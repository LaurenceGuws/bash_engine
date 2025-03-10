# Set buffer editor for Nushell
$env.config.buffer_editor = "nvim"

# Load environment variables from your YAML config
# Since Nushell doesn’t parse YAML automatically like Bash, we define them explicitly

# Active bot for bot alias
$env.ACTIVE_BOT = "phi4:latest"

# Socket for SSH authentication
$env.SSH_AUTH_SOCK = $"($env.HOME)/.1password/agent.sock"

# Default apps
$env.EDITOR = "nvim"
$env.XDG_CONFIG_HOME = $"($env.HOME)/.config"
$env.MANPAGER = "page"
$env.PAGER = "page"
$env.BROWSER = "brave"
# $env.TERMINAL = "kitty"  # Uncomment if needed
$env.BANNER_DISABLED = "true"
$env.BLOG_DISABLED = "true"
$env.THEME = "catppuccin_goose"
$env.THEME_DIR = $"($env.HOME)/.cache/oh-my-posh/themes"

# FZF default options
$env.FZF_DEFAULT_OPTS = "--color=bg+:-1,bg:-1,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --color=selected-bg:-1 --multi"

# NNN settings
$env.NNN_FCOLORS = "D4DE9F78E79F9F67D2E5E5D2"
$env.NNN_PLUG = "b:nnn_cd.sh;p:preview-tui"
$env.NNN_BMS = $"p:($env.HOME)/personal;w:($env.HOME)/work;l:($env.HOME)/personal/linux_profile/;c:($env.HOME)/.config/"
$env.NNN_FIFO = "/tmp/nnn.fifo"

# OP.nvim path
$env.OP_NVIM = $"($env.HOME)/.local/share/nvim/lazy/op.nvim/bin"
