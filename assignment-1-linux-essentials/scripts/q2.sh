#!/bin/bash

echo "Kernel Name:"
uname -s
echo

echo "CPU Percentages (from top):"
top -bn1 | grep "Cpu(s)"
# This line contains: user%, system%, idle%
echo

echo "Number of running processes:"
ps -e --no-headers | wc -l
echo

echo "Free Storage:"
df -h /