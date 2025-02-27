#!/bin/bash
browsh() {
    if [ -t 1 ]; then
        # Run with interactive TTY if attached to a terminal
        docker run --rm -it --net=host browsh/browsh "$@"
    else
        # Run without TTY for non-interactive sessions
        docker run --rm --net=host browsh/browsh "$@"
    fi
}
