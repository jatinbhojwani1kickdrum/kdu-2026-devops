#!/bin/bash

LOG_FILE="./q1.log"

PARENT_DIR="$1"

if [ -z "$PARENT_DIR" ]; then
  echo "Usage: $0 <parent_directory>"
  exit 1
fi

if [ ! -d "$PARENT_DIR" ]; then
  echo "Parent directory does not exist: $PARENT_DIR"
  exit 1
fi

echo "Logging to $LOG_FILE"
echo "---- $(date) ----" >> "$LOG_FILE"

for dir in "$PARENT_DIR"/*; do
  if [ -d "$dir" ]; then
    echo "Directory: $dir" >> "$LOG_FILE"
    for f in "$dir"/*; do
      if [ -f "$f" ]; then
        echo "$(basename "$f")" | tee -a "$LOG_FILE"
      fi
    done
  fi
done