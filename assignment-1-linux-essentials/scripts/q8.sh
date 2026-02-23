#!/bin/bash

# Usage: ./q8.sh <directory> <search_pattern> <replace_pattern>

DIR="$1"
SEARCH="$2"
REPLACE="$3"

if [ -z "$DIR" ] || [ -z "$SEARCH" ] || [ -z "$REPLACE" ]; then
  echo "Usage: $0 <directory> <search_pattern> <replace_pattern>"
  exit 1
fi

for file in "$DIR"/*; do
  if [ -f "$file" ]; then
    sed -i "s/$SEARCH/$REPLACE/g" "$file"
    echo "Updated: $file"
  fi
done