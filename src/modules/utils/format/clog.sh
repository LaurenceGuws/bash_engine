#!/bin/bash

clog() {
  sed -E \
    -e "s/^(\[[0-9:., -]+\])/\x1b[36m&\x1b[0m/" \
    -e "s/ (\[.*\]) /\x1b[34m&\x1b[0m /" \
    -e "s/ TRACE /\x1b[35mTRACE\x1b[0m\n/" \
    -e "s/ DEBUG /\x1b[36mDEBUG\x1b[0m\n/" \
    -e "s/ INFO /\x1b[32mINFO\x1b[0m\n/" \
    -e "s/ WARN /\x1b[33mWARN\x1b[0m\n/" \
    -e "s/ ERROR /\x1b[31mERROR\x1b[0m\n/" \
    -e "s/ FATAL /\x1b[1;31mFATAL\x1b[0m\n/" \
    -e "s/\{([^}]*)\} - /\x1b[35m{\1}\x1b[0m\n - /" \
    -e "s/\(([^)]*)\)/\x1b[35m&\x1b[0m/" \
    -e "s/\[([^\]]*)\]/\x1b[34m&\x1b[0m/" \
    -e "s/<([^>]*)>/\x1b[36m&\x1b[0m/" \
    -e "/TRACE|DEBUG|INFO|WARN|ERROR|FATAL/ s/^/--------------------------------------------------------------------------------\n/"
}

# Usage:
# Pipe any log output into 'clog' for colorization
# docker logs -f wso2is 
# tail -f /var/log/syslog 
