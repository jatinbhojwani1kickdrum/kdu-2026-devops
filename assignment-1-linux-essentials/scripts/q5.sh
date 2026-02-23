#!/bin/bash

# Usage: ./q5.sh <ec2_public_ip> <ssh_key_path> <username>

EC2_IP="$1"
KEY="$2"
USER="$3"

LOCAL_DIR="./local_files"
ARCHIVE="files.tar.gz"

if [ -z "$EC2_IP" ] || [ -z "$KEY" ] || [ -z "$USER" ]; then
  echo "Usage: $0 <ec2_public_ip> <ssh_key_path> <username>"
  exit 1
fi

mkdir -p "$LOCAL_DIR"
echo "file1" > "$LOCAL_DIR/file1.txt"
echo "file2" > "$LOCAL_DIR/file2.txt"
echo "file3" > "$LOCAL_DIR/file3.txt"

tar -czf "$ARCHIVE" "$LOCAL_DIR"

REMOTE_DIR="/home/$USER/Downloads"

echo "Uploading archive to EC2..."
scp -i "$KEY" "$ARCHIVE" "$USER@$EC2_IP:$REMOTE_DIR/"

echo "Downloading archive back to local /Users/$USER/Downloads ..."
scp -i "$KEY" "$USER@$EC2_IP:$REMOTE_DIR/$ARCHIVE" /mnt/c/Users/Admin/Downloads/