#!/bin/bash

get_url="https://jsonplaceholder.typicode.com/posts/1"
post_url="https://jsonplaceholder.typicode.com/posts"
post_data='{"title":"foo","body":"bar","userId":1}'

echo "GET Request:"
curl -s "$get_url"
echo
echo

echo "POST Request:"
curl -s -X POST "$post_url" \
  -H "Content-Type: application/json" \
  -d "$post_data"
echo