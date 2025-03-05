#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)" #Get the directory of the script <sikraken_install>/bin
SIKRAKEN_INSTALL_DIR="$SCRIPT_DIR/.."
echo "Sikraken call_parser.sh says: SIKRAKEN_INSTALL_DIR is $SIKRAKEN_INSTALL_DIR"

# Ensure we have at least 2 arguments
if [ $# -lt 2 ]; then
    echo "call_parser.sh usage: $0 <source_directory> <file_no_ext> [gcc_flag]"
    exit 1
fi

input_file_no_ext="$2"
output_file="$input_file_no_ext.i"
source_directory="$1"
output_directory="$SIKRAKEN_INSTALL_DIR/sikraken_output/$input_file_no_ext"

# Optional third argument for data_model, default to '-m32' if absent
gcc_flag="${3:--m32}"

if [ ! -d "$output_directory" ]; then  # If it doesn't exist, create it
    mkdir -p "$output_directory"
fi

# Preprocess the file using gcc
gcc -E -P "$source_directory/$input_file_no_ext.c" $gcc_flag -o "$output_directory/$output_file"

# Check if gcc was successful
if [ $? -ne 0 ]; then
    echo "Sikraken call_parser.sh error: gcc failed on gcc -E -P "$source_directory/$input_file_no_ext.c" $gcc_flag -o "$output_directory/$output_file""
    exit 1
fi

# Run the parser
./bin/sikraken_parser.exe -d $gcc_flag -p"$output_directory" "$input_file_no_ext"

# Check if sikraken_parser was successful
if [ $? -ne 0 ]; then
    echo "Error: sikraken_parser failed on ./bin/sikraken_parser.exe -d $gcc_flag -p"$output_directory" "$input_file_no_ext""
    exit 1
fi

echo "Successfully preprocessed $input_file_no_ext and ran sikraken_parser."