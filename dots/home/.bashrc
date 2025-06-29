# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# PS1='[\u@\h \W]\$ '

export CUDA_HOME=/opt/cuda
export PATH=$PATH:/opt/cuda/bin

alias ff="fastfetch"

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd <"$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}
export STARSHIP_CONFIG=/home/home/.config/starship/starship.toml
eval "$(starship init bash)"

source /usr/share/zsh/plugins/forgit/forgit.plugin.zsh
source ~/.local/share/bash-completion/completions/git-forgit.bash
# >>> add-to-profile.sh START >>>
export PROFILE_DIR="/home/home/personal/bash_engine"
source "$PROFILE_DIR/src/core/core_init.sh"
# <<< add-to-profile.sh END <<<

# export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# export NVM_DIR="$HOME/.config/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
