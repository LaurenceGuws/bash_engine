
http2ssh(){
    find . -type d -name ".git" -exec sh -c '
        cd "$(dirname "{}")" || exit
        for remote in $(git remote); do
            old_url=$(git remote get-url "$remote")
            new_url=$(echo "$old_url" | sed -E "s|https://([^/]+)/([^/]+)/([^ ]+).git|git@\1:\2/\3.git|")
            if [ "$old_url" != "$new_url" ]; then
                git remote set-url "$remote" "$new_url"
                echo "Updated $remote in $(pwd)"
            fi
        done
    ' 
}

