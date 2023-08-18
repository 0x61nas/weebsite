#!/usr/bin/env just --justfile
export PATH := "./node_modules/.bin:" + env_var('PATH')

alias s := serve
alias ss := serve-fresh
alias c := clean

# Build the website and serve it
serve:
    zola serve

# Remove the old output directory and serve
serve-fresh: clean serve

# Remove the `public` directory
clean:
    rm -rf {{justfile_directory()}}/public
