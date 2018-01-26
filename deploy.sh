#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Commit changes.
msg="Rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Build the project.
hugo

# Checkout to master
git checkout master
# Add changes to git.
git add .
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come back to develop
git checkout develop
