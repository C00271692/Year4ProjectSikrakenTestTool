#!/bin/bash
#e.g. ./bin/test_category_sikraken.sh /home/chris/sv-benchmarks/c ECA 8 30 debug
# Run all the benchmarks in a TestComp category as defined in the sv-benchmarks/c directory in parallel
# Outputs logs files in SikrakenDevSpace/categories/<category>/<timestamp>/
# Takes into account possible exclude set for ECA
# Generates test inputs for each benchmark and run TestCov on them
# Generates a summary table for the category
# Updates the category summary table for all the previous runs
# Generates a runtime graph for each benchmark
# Plays a sound at the end of the run
clear
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)" #Get the directory of the script <sikraken_install>/bin
SIKRAKEN_INSTALL_DIR="$SCRIPT_DIR/.."

echo "Run all the benchmarks from a TestComp category using SIKRAKEN_INSTALL_DIR is $SIKRAKEN_INSTALL_DIR"
# Ensure we have 5 arguments
if [ ! $# -eq 5 ]; then
    echo "$0.sh usage: $0 <path_to_benchmarks> <category> <cores> <budget> <mode>"
    exit 1
fi

path_to_benchmarks="$1" #e.g. /home/chris/sv-benchmarks/c
category="$2"           #e.g. ECA
cores=$3                #e.g. 6
budget=$4               #e.g. 900
mode=$5                 #e.g. debug or release

# Check if the path_to_benchmarks exists
if [ ! -d "$path_to_benchmarks" ]; then
    echo "ERROR: the passed path to benchmarks $path_to_benchmarks does not exist."
    exit 1
fi

category_file="$category".set
full_path_to_category_file="$path_to_benchmarks/$category_file"

# Check if the category file exists
if [ ! -f "$full_path_to_category_file" ]; then
    echo "ERROR: the file of categories $category_file does not exist in $path_to_benchmarks"
    exit 1
fi
# Define exclusion set for ECA
exclude_set=""
if [ $category == "ECA" ]; then
    exclude_set="$SCRIPT_DIR/../SikrakenDevSpace/ECA-excludes.set"
    if [ ! -f "$exclude_set" ]; then
        echo "ERROR: Exclusion set $exclude_set does not exist."
        exit 1
    fi
    echo "Using the exclude set: "$exclude_set""
fi

echo "Script called: "$0 $@""

# re-compile the parser in case it changed during development
./bin/compile_parser.sh
if [ $? -ne 0 ]; then
    echo "ERROR: Sikraken parser recompilation failed"
    exit 1
else
    echo "Sikraken parser successfully recompiled"
fi

timestamp=$(date +"%Y_%b_%d_%I_%M%p")
output_dir="./SikrakenDevSpace/categories/$category/$timestamp"
echo "The output dir is $output_dir"
mkdir -p "$output_dir"

# Job pool to limit the number of background processes
job_pool() {
    while [ "$(jobs -r | wc -l)" -ge "$cores" ]; do
        sleep 1  # Wait for an available slot
    done
}

#generate tests based on 
generate_tests() {
    local benchmark="$1"
    local gcc_flag="$2"

    # Extract the basename of the file (without the path nor extension)
    local basename=$(basename "$benchmark")
    basename="${basename%.*}"
    local dirname=$(dirname "$benchmark")
    local benchmark_output_dir="$output_dir"/"$basename"
    mkdir -p "$benchmark_output_dir"
    local log_file="$benchmark_output_dir"/sikraken.log  
    echo "debug: the log_file is $log_file" 
    
    local parsed_dir="$SIKRAKEN_INSTALL_DIR/sikraken_output/$basename"
    mkdir -p $parsed_dir

    # Check the file extension
    file_extension="${benchmark##*.}"
    if [ "$file_extension" == "i" ]; then
        # If the file is already preprocessed (.i), just copy it to $output_dir
        cp "$benchmark" "$parsed_dir/" >> $log_file 2>&1
        if [ $? -ne 0 ]; then
            echo "Error: Failed to copy $benchmark to $parsed_dir" >> $log_file 
            return 1
        fi
    else
        # If the file is not preprocessed, preprocess it with gcc
        gcc -E -P "$benchmark" $gcc_flag -o "$parsed_dir/$basename.i" >> $log_file 2>&1
        if [ $? -ne 0 ]; then
            echo "Error: gcc failed on gcc -E -P "$benchmark" $gcc_flag -o "$parsed_dir/$basename.i"" >> $log_file
            return 1
        fi
    fi

    # Run the parser on foo.i
    $SIKRAKEN_INSTALL_DIR/bin/sikraken_parser.exe $gcc_flag -p$parsed_dir $basename >> $log_file 2>&1

    echo -e "Generating tests for $basename using a budget of $budget seconds" >> $log_file

    # Generate test inputs
    local eclipse_call="$SIKRAKEN_INSTALL_DIR/eclipse/bin/x86_64_linux/eclipse -f $SIKRAKEN_INSTALL_DIR/SymbolicExecutor/se_main.pl -e \"se_main(['$SIKRAKEN_INSTALL_DIR', '${SIKRAKEN_INSTALL_DIR}/${rel_path_c_file}', '$basename', main, $mode, testcomp, '$gcc_flag', budget($budget)])\""
    eval $eclipse_call  >> $log_file 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR: Call to ECLiPSe $eclipse_call failed"  >> $log_file
        return 1
    else
        echo "Test inputs generated for "$basename" using $eclipse_call"
    fi

    #generate graph
    ./bin/runtime_graph.sh "$log_file" >> $log_file
}

### main starts here
# Capture start times
start_wall_time=$(date +"%Y-%m-%d %H:%M:%S")

category_extracted_benchmarks_files=$"$output_dir"/benchmark_files.txt

grep -o '.*\/.*\.yml' "$full_path_to_category_file" | while read -r pattern_benchmark_directory; do
    
    # e.g. for all the *.yml matching pattern_benchmark_directory eca-rers2012/*.yml
    for yml_file in $path_to_benchmarks/$pattern_benchmark_directory; do
        # Exclude files listed in the exclusion set
        if [ -n "$exclude_set" ] && grep -Fxq "$yml_file" "$exclude_set"; then
            echo "Skipping excluded file: $yml_file"
            continue
        fi
        echo "yml_file is $yml_file"
        if [ -f "$yml_file" ]; then
            # Check if the file contains the required property_file line
            if grep -qE "^\s*- property_file: \.\./properties/coverage-branches\.prp$" "$yml_file"; then
                echo "Extracting benchmark file from $yml_file"

                # Extract the input file (match "input_files: <filename>" for .c or .i files)
                benchmark=$(grep "input_files:" "$yml_file" | sed -n "s/^[[:space:]]*input_files:[[:space:]]*\(['\"]\?\)\(.*\)\1/\2/p")

                # Extract the data model
                data_model=$(grep "data_model:" "$yml_file" | sed -n "s/^[[:space:]]*data_model:[[:space:]]*\(.*\)/\1/p")

                # Generate GCC flag based on the value of data_model
                if [ "$data_model" == "ILP32" ]; then
                    gcc_flag="-m32"
                    testcov_data_model="-32"
                elif [ "$data_model" == "LP64" ]; then
                    gcc_flag="-m64"
                    testcov_data_model="-64"
                else
                    echo "ERROR: Unsupported data model: $data_model"
                fi
                full_path_benchmark_file="$(dirname $yml_file)/$benchmark"
                # write each file in the benchmark category into $category_extracted_benchmarks_files for testcov to use
                echo "$full_path_benchmark_file $testcov_data_model" >> $category_extracted_benchmarks_files
                
                job_pool  # Wait for an available slot
            
                generate_tests "$full_path_benchmark_file" "$gcc_flag" &  # Run in the background
            fi  # if the .yml file does not contain the correct property, it is silently skipped
        fi
    done #no more *.yml file
done

wait    # Wait for all background jobs to finish before running TestCov sequentially

# merge all the  sikraken.log 


# Capture end times
end_wall_time=$(date +"%Y-%m-%d %H:%M:%S")
echo "Start Wall Time: $start_wall_time"
echo "End Wall Time: $end_wall_time"
echo "Running TestCov sequentially"
./bin/test_category_testcov.sh $path_to_benchmarks $output_dir
after_testcov_wall_time=$(date +"%Y-%m-%d %H:%M:%S")
echo "After TestCov Wall Time: $after_testcov_wall_time"

budget=$4               #e.g. 900
generate_table_script="./bin/test_category_generate_table.sh "$output_dir" $budget $mode"
echo "now calling $generate_table_script"
$generate_table_script

# update the category summary table for all the previous runs
./SikrakenDevSpace/bin/view_category.sh ./SikrakenDevSpace/categories/$category/

echo "Sikraken $0 has ended."
aplay SikrakenDevSpace/call_to_arms.wav