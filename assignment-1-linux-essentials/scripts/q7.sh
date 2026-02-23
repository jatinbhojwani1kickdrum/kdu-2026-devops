#!/bin/bash

TARGET="$1"
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <target_directory>"
  exit 1
fi

# Directories: owner read+execute only => 500
find "$TARGET" -type d -exec chmod 500 {} \;

# Shell scripts: executable for all => 755
find "$TARGET" -type f -name "*.sh" -exec chmod 755 {} \;

# Regular files (excluding .sh): read-only for all => 444
find "$TARGET" -type f ! -name "*.sh" -exec chmod 444 {} \;

echo "Permissions updated."