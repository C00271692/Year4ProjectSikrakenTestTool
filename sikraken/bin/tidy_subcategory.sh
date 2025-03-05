#!/bin/bash

# Directory to search for files
DIRECTORY=${1:-.}  # Use the first argument as directory or default to current directory

# The string to search for
SEARCH_STRING="property_file: ../properties/coverage-branches.prp"

# Iterate through all *.c files in the directory
find "$DIRECTORY" -type f -name "*.c" | while read -r c_file; do
  # Get the corresponding .yml file
  yml_file="${c_file%.c}.yml"

  # Check if the .yml file exists and contains the search string
  if [[ ! -f "$yml_file" ]] || ! grep -qF "$SEARCH_STRING" "$yml_file"; then
    # If the .yml file doesn't exist or the string is not found, delete the .c file
    echo "Deleting $c_file as $yml_file does not contain the required string."
    rm "$c_file"
  fi
done
