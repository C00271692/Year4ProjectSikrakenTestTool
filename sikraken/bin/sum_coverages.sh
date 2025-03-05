#!/bin/bash

# Check if the file argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file>"
  exit 1
fi

# File containing the percentage values
file="$1"

# Extract the percentage values, remove the '%' symbol, and sum them
total=$(grep -oP 'Coverage: \K[\d.]+(?=%)' "$file" | awk '{sum += $1} END {print sum / 100}')

echo "Total raw score: $total"