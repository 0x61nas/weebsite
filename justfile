#!/usr/bin/env just --justfile
export PATH := "./node_modules/.bin:" + env_var('PATH')

_description := "A new blog post"

alias s := serve
alias ss := serve-fresh
alias c := clean

# Create a new post
post title description=_description:
    #!/usr/bin/env sh
    set -euxo pipefail
    # Get the directory name (title in kebab-case)
    directory=$(echo {{title}} | sed -E 's/[^a-zA-Z0-9]+/-/g' | tr '[:upper:]' '[:lower:]')
    # Get the date
    date=$(date +%Y-%m-%d)
    # Create a new branch
    git checkout -b "post/$directory"
    # Create the post directory
    mkdir -p {{justfile_directory()}}/content/$directory
    # Create the post file
    cp {{justfile_directory()}}/templ/post.md {{justfile_directory()}}/content/$directory/index.md
    # Patch the template
    sed -i '' -E "s/DATE/$date/g" {{justfile_directory()}}/content/$directory/index.md
    sed -i '' -E "s/TITLE/{{title}}/g" {{justfile_directory()}}/content/$directory/index.md
    sed -i '' -E "s/DESCRIPTION/{{description}}/g" {{justfile_directory()}}/content/$directory/index.md
    # Record the changes
    git add {{justfile_directory()}}/content/$directory/index.md
    # Commit the changes
    git commit -m -S "feat(post): create {{title}} post"
    # Push the changes
    git push --set-upstream draft "post/$directory"
    # open the post in the editor
    $EDITOR {{justfile_directory()}}/content/$directory/index.md

# Push the changes to all remotes. [WARNING] don't use this when u workin on a secret branch. call `git push` manually
push:
    #!/usr/bin/env sh
    set -euxo pipefail
    remotes=$(git remote)
    for remote in $remotes; do
        git push $remote
    done
    # Reset the upstream remote to origin(github)
    git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)

# Build the website and serve it
serve *args:
    zola serve {{args}}

# Remove the old output directory and serve
serve-fresh: clean serve

# Remove the `public` directory
clean:
    rm -rf {{justfile_directory()}}/public
