#!/bin/bash

pull(){
 cd "$PROFILE_DIR" || exit
 git pull
}

push(){
    cd "$PROFILE_DIR" || exit
    git add .
    git commit -m 'auto commit via update.sh'
    git push 
}