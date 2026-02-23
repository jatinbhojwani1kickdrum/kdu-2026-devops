#!/bin/bash

# Usage: ./q6.sh <repo_url>

REPO_URL="$1"
if [ -z "$REPO_URL" ]; then
  echo "Usage: $0 <repo_url>"
  exit 1
fi

git clone "$REPO_URL"
REPO_NAME=$(basename "$REPO_URL" .git)

cd "$REPO_NAME" || exit 1

echo "Listing contents:"
ls -la

echo "Creating new file..."
echo "hello" > newfile.txt

echo "Creating new branch..."
git checkout -b assignment-1-linux-essentials

echo "Committing..."
git add newfile.txt
git commit -m "Add new file"

echo "Pushing branch..."
git push -u origin assignment-1-linux-essentials