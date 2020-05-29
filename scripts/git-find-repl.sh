#!/bin/sh

# Find and Replace on all files in a git repo
# usage: git-find-repl.sh <find_str> <replace_dir>

git grep -Il "$1" | xargs sed -i '' -e "s/$1/$2/g"
