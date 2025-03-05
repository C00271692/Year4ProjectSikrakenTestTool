#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)" #Get the directory of the script <sikraken_install>/bin
SIKRAKEN_INSTALL_DIR="$SCRIPT_DIR/.."

echo "Run TestCov after a Sikraken Category test run from SIKRAKEN_INSTALL_DIR is $SIKRAKEN_INSTALL_DIR"
# Ensure we have 2 arguments
if [ ! $# -eq 2 ]; then
    echo "$0.sh usage: $0 <path_to_benchmarks> <category>"
    exit 1
fi

path_to_benchmarks="$1"     #e.g. /home/chris/sv-benchmarks/c
sikraken_test_run_dir="$2"  #e.g. SikrakenDevSpace/categories/Termination-MainControlFlow/2024_Dec_01_07_04AM


# Check if the path_to_benchmarks exists
if [ ! -d "$path_to_benchmarks" ]; then
    echo "ERROR: the passed path to benchmarks $path_to_benchmarks does not exist."
    exit 1
fi

# Check if the sikraken_test_run_dir exists
if [ ! -d "$sikraken_test_run_dir" ]; then
    echo "ERROR: the passed path to to the sikraken category test run $sikraken_test_run_dir does not exist."
    exit 1
fi

echo "Script called: "$0 $@""

### main starts here
category_extracted_benchmarks_files=$"$sikraken_test_run_dir"/benchmark_files.txt

# Run testcov sequentially [because I can't find a way to make it run in parallel even in so-called isolation mode and/or runexec]
# Iterate over each line in the file
while IFS= read -r line; do
    # Extract the file path (first field) and the second argument
    benchmark_file_path=$(echo "$line" | awk '{print $1}')          # First field
    testcov_data_model=$(echo "$line" | awk '{print $2}') # Second field

    # Extract the basename of the benchmark (without the path nor extension)
    benchmark_basename=$(basename "$benchmark_file_path")
    benchmark_basename="${benchmark_basename%.*}"

    zipfile="./sikraken_output/$benchmark_basename/test-suite.zip"
    rm -f $zipfile
    zip -r $zipfile "./sikraken_output/$benchmark_basename/test-suite"

    testcov_output_dir=""$sikraken_test_run_dir"/"$benchmark_basename"/testcov"
    echo "Debug testcov_output_dir is $testcov_output_dir"
    if [ -d "$testcov_output_dir" ]; then   #from a previous (perhaps failed) run
        rm -rf "$testcov_output_dir"
    fi
    mkdir -p "$testcov_output_dir"

    testcov_call="testcov $testcov_data_model --test-suite $zipfile $benchmark_file_path --output "$testcov_output_dir" --reduction NONE --no-runexec --no-isolation --no-plots"
    echo "CALL TO TESTCOV IS $testcov_call"
    $testcov_call > ""$testcov_output_dir"/testcov_call.log" 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR: TestCov validation failed for $benchmark_file_path"
    fi
done < "$category_extracted_benchmarks_files"

echo "Sikraken $0 has ended."