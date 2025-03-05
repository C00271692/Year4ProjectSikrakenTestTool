#!/bin/bash

clear
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)" #Get the directory of the script <sikraken_install>/bin
SIKRAKEN_INSTALL_DIR="$SCRIPT_DIR/.."

echo "ENLARGE subset: crash and learn; SIKRAKEN_INSTALL_DIR is $SIKRAKEN_INSTALL_DIR"
# Ensure we have at least 2 arguments
if [ $# -lt 2 ]; then
    echo "$0.sh usage: $0 <directory_of_c_files> <budget>"
    exit 1
fi

# Set the directory containing the .c files from the argument
c_files_directory="$1"
budget="$2"

# Check if the provided directory exists
if [ ! -d "$c_files_directory" ]; then
    echo "Sikraken ENLARGE subset ERROR: the passed directory of files $c_files_directory does not exist."
    exit 1
fi

# re-compile the parser in case it changed during development
./bin/compile_parser.sh
if [ $? -ne 0 ]; then
    echo "Sikraken ENLARGE subset ERROR: Sikraken parser recompilation failed"
    exit 1
else
    echo "Sikraken parser successfully recompiled"
fi
timestamp=$(date +"%Y%m%d_%H%M%S")
log_output_dir="$c_files_directory"/"$timestamp"
echo "DEBUG $log_output_dir"
mkdir -p "$log_output_dir"
# Loop over all .c files in the directory
for regression_test_file in "$c_files_directory"/*.c; do

    # Extract the base name of the file (without the path and extension)
    base_name=$(basename "$regression_test_file" .c)
    yml_file="$c_files_directory"/"$base_name".yml

    # Check if the testcomp yml file exists
    if [ ! -f "$yml_file" ]; then
        echo "Sikraken ENLARGE subset WARNING: .yml file $yml_file does not exist, assuming ILP32"
        data_model="ILP32"
    else
        input_test_file=$(grep "input_files:" "$yml_file" | awk '{print $2}')  #overwrites the regression_test_file
        input_test_file="${input_test_file//\'/}"  # Remove single quotes
        file_extension="${input_test_file##*.}"
        echo "Sikraken ENLARGE: input_test_file file is $input_test_file"
        base_name="${input_test_file%.*}"
        echo "Sikraken ENLARGE: nasename $base_name"
        if [ "$file_extension" == "i" ]; then
            echo "Sikraken ENLARGE: processing the .i file: $base_name"
             if [ -f "$c_files_directory"/"$input_test_file" ]; then     # if the file exists
                echo "Sikraken ENLARGE: the regression_test_file exist: $input_test_file"
                # the file is already preprocessed (.i), delete the .c and rename the .i
                echo "Sikraken ENLARGE: running rm "$c_files_directory"/"$base_name".c"
                rm "$c_files_directory"/"$base_name".c
                echo "Sikraken ENLARGE: running rm "$c_files_directory"/"$base_name".i "$c_files_directory"/"$base_name".c"
                mv "$c_files_directory"/"$base_name".i "$c_files_directory"/"$base_name".c
             fi
        fi
        data_model=$(grep "data_model:" "$yml_file" | awk '{print $2}') # $2 is the second field of the line containing "data_model:"
    fi

    # Generate GCC flag based on the value of data_model
    if [ "$data_model" == "ILP32" ]; then
        gcc_flag="-m32"
        testcov_data_model="-32"
    elif [ "$data_model" == "LP64" ]; then
        gcc_flag="-m64"
        testcov_data_model="-64"
    else
        echo "Sikraken ENLARGE subset ERROR: Unsupported data model: $data_model"
        exit 1
    fi

    #preprocess the C file using gcc and parse using Sikraken's parser
    ./bin/call_parser.sh $c_files_directory $base_name $gcc_flag
    if [ $? -ne 0 ]; then
        echo "Sikraken ENLARGE subset ERROR: Sikraken parsing of $base_name failed"
    else
        echo "Sikraken successfully called ./bin/call_parser.sh $c_files_directory $base_name $gcc_flag"
    fi

    #generate test inputs
    eclipse_call="se_main(['/home/chris/Sikraken', '$c_files_directory', '$base_name', main, debug, testcomp, '$gcc_flag', budget($budget)])"
    $SIKRAKEN_INSTALL_DIR/eclipse/bin/x86_64_linux/eclipse -f $SIKRAKEN_INSTALL_DIR/SymbolicExecutor/se_main.pl -e "$eclipse_call" -g 12G -l 1G > "$log_output_dir/$base_name.log"

    if [ $? -ne 0 ]; then
        echo "Sikraken ENLARGE subset ERROR: call to ECLiPSe $eclipse_call failed"
    else
        echo "Sikraken ENLARGE subset generated test inputs for $regression_test_file in $id configuration"
    fi
    #generate graph
    ./bin/runtime_graph.sh "$log_output_dir/$base_name.log"

    #validate test inputs
    $SIKRAKEN_INSTALL_DIR/bin/run_testcov.sh $regression_test_file $testcov_data_model > "$log_output_dir/$base_name.testcov"
    if [ $? -ne 0 ]; then
        echo "Sikraken ENLARGE subset ERROR: TestCov test inputs validation of $regression_test_file failed"
    else
        echo "TestCov validated the test inputs for $regression_test_file in $id configuration"    
    fi

done