#!/bin/bash

# Script name: compile_parser.sh
# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIKRAKEN_INSTALL_DIR="$SCRIPT_DIR/.."
echo "SIKRAKEN_INSTALL_DIR is $SIKRAKEN_INSTALL_DIR"

# Change the current directory using the script's directory
cd "$SIKRAKEN_INSTALL_DIR/Parser"

# Run the flex command
flex "C_grammar.l"

# Check if the flex command was successful
if [ $? -ne 0 ]; then
    echo "Error: flex failed to process C_grammar.l"
    exit 1
else
    echo "flex successfully processed C_grammar.l"
fi

# Run the bison command
bison "C_grammar.y"

# Check if the bison command was successful
if [ $? -ne 0 ]; then
    echo "Error: bison failed to process C_grammar.y"
    exit 1
else
    echo "bison successfully processed C_grammar.y"
fi

# Run the gcc command to compile the generated C code
gcc -trigraphs "C_grammar.tab.c" -o "$SIKRAKEN_INSTALL_DIR/bin/sikraken_parser.exe"

# Check if the gcc command was successful
if [ $? -ne 0 ]; then
    echo "Error: gcc failed to compile C_grammar.tab.c"
    exit 1
else
    echo "gcc successfully compiled sikraken_parser to "$SIKRAKEN_INSTALL_DIR/bin/sikraken_parser.exe""
fi
