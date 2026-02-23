#!/bin/bash

url="https://www.kickdrum.com/case-studies"
outfile="case-studies.html"

echo "Downloading with wget..."
wget -O "$outfile" "$url"

echo
echo "Downloading with curl (progress)..."
curl -o "case-studies-curl.html" "$url"