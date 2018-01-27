#!/bin/bash

# 0. Notify & get message
echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
msg="Rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi

# 1. Commit changes to develop first
git add .
git commit -m "$msg"

# 2. Build the project in develop
hugo

# 3. Checkout to master
git checkout master

# 4. Add changes to master
mv public/* .
git add .
git commit -m "$msg"

# 5. Push to develop & master
git push origin master develop

# 6. Come back to develop
git checkout develop
