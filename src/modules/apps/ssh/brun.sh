#!/bin/bash

brun () {
    nohup waypipe --no-gpu ssh brommer "$@" --ozone-platform=wayland >/dev/null 2>&1 &
}


