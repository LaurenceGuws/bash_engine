# Increase history size
export HISTSIZE=1000000                # Number of commands stored in memory
export HISTFILESIZE=2000000            # Number of commands stored in the history file

# Append to history file instead of overwriting
shopt -s histappend

# Prevent duplicate entries
HISTCONTROL=ignoredups:erasedups

# Save history after each command (this might be very disorienting if you're not use to it...)
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
