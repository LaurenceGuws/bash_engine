#!/usr/bin/env bash

fgit() {

    # Pick one or more authors with multi-select
    authors=$(git log --all --format='%aN <%aE>' | sort -u |
        fzf --multi --prompt="Select author(s): ")

    # Exit if none selected
    [ -z "$authors" ] && exit 1

    # Build git log filter: multiple --author flags
    author_args=()
    while IFS= read -r a; do
        author_args+=(--author="$a")
    done <<<"$authors"

    # Show commits for selected authors
    git log --all "${author_args[@]}" \
        --pretty=format:'%Cgreen%cd %Creset%s' --date=short |
        fzf --no-sort --reverse --tiebreak=index \
            --preview-window=down:70%:wrap \
            --prompt="Commits by selected author(s) > " \
            --preview '
        commit_date=$(echo {} | awk "{print \$1}")
        commit_subject=$(echo {} | cut -d" " -f2-)
        commit_hash=$(git log --all --grep="$commit_subject" --since="$commit_date" \
                        --pretty=format:"%H" -n 1)
        git show --color=always "$commit_hash" | delta --paging=never
      '
}
