#!/bin/bash

clear
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)" #Get the directory of the script <sikraken_install>/bin
SIKRAKEN_INSTALL_DIR="$SCRIPT_DIR/.."
echo "Sikraken regression testing run_regression.sh says: SIKRAKEN_INSTALL_DIR is $SIKRAKEN_INSTALL_DIR"

# Check if the directory argument is provided
if [ -z "$1" ]; then
    echo "Sikraken regression testing ERROR: script usage is $0 <relative_directory_of_regression_c_files> e.g. regression_tests"
    exit 1
fi

# Set the directory containing the .c files from the argument
rel_path_c_file="$1"
c_files_directory="$SIKRAKEN_INSTALL_DIR/$rel_path_c_file"    #e.g. /home/chris/Sikraken/regression_tests

# Check if the provided directory exists
if [ ! -d "$c_files_directory" ]; then
    echo "Sikraken regression testing ERROR: the passed directory of regression files $c_files_directory does not exist."
    exit 1
fi

# re-compile the parser in case it changed during development
./bin/compile_parser.sh
if [ $? -ne 0 ]; then
    echo "Sikraken regression testing ERROR: Sikraken parser recompilation failed"
    exit 1
else
    echo "Sikraken parser successfully recompiled"
fi

if [ -f regression_tests_run.log ]; then
    rm -f regression_tests_run.log
fi

# Loop over all .c files in the directory
for regression_test_file in "$c_files_directory"/*.c; do

    # Extract the base name of the file (without the path nor extension)
    base_name=$(basename "$regression_test_file" .c)
    config_file="$c_files_directory"/"$base_name".json
    yml_file="$c_files_directory"/"$base_name".yml

    # Check if our configuration file exists
    if [ ! -f "$config_file" ]; then
        echo "Sikraken regression testing ERROR: Configuration file $config_file does not exist"
        exit 1
    fi

    # Check if the testcomp yml file exists
    if [ ! -f "$yml_file" ]; then
        echo "Sikraken regression testing WARNING: .yml file $yml_file does not exist, assuming ILP32"
        data_model="ILP32"
    else
        data_model=$(grep "data_model:" "$yml_file" | awk '{print $2}')
    fi

    # Generate GCC flag based on the value of data_model
    if [ "$data_model" == "ILP32" ]; then
        gcc_flag="-m32"
        testcov_data_model="-32"
    elif [ "$data_model" == "LP64" ]; then
        gcc_flag="-m64"
        testcov_data_model="-64"
    else
        echo "Sikraken regression testing ERROR: Unsupported data model: $data_model"
        exit 1
    fi

    #preprocess the regression test using gcc and parse using Sikraken's parser
    $SIKRAKEN_INSTALL_DIR/bin/call_parser.sh $SIKRAKEN_INSTALL_DIR/$rel_path_c_file $base_name $gcc_flag
    if [ $? -ne 0 ]; then
        echo "Sikraken regression testing ERROR: Sikraken parsing of $regression_test_file failed using $SIKRAKEN_INSTALL_DIR/bin/call_parser.sh $SIKRAKEN_INSTALL_DIR/$rel_path_c_file $base_name $gcc_flag"
        exit 1
    else
        echo "Sikraken successfully parsed $regression_test_file"
    fi

    # Loop over all configurations in the configuration file
    config_count=$(jq '.configurations | length' "$config_file")

    for i in $(seq 0 $((config_count - 1))); do
        # Extract the configuration data
        config=$(jq ".configurations[$i]" "$config_file")

        id=$(echo "$config" | jq -r '.id')
        description=$(echo "$config" | jq -r '.description')
        algo=$(echo "$config" | jq -r '.algo')
        #restarts=$(echo "$config" | jq -r '.restarts')
        #tries=$(echo "$config" | jq -r '.tries')
        expected_run_time=$(echo "$config" | jq -r '.expected_run_time')
        expected_test_inputs_number=$(echo "$config" | jq -r '.expected_test_inputs_number')
        expected_coverage=$(echo "$config" | jq -r '.expected_coverage')

        echo -e "\e[34mSikraken regression testing script now generating tests for $regression_test_file in $id configuration.\e[0m"

        #generate test inputs
        eclipse_call="se_main(['$SIKRAKEN_INSTALL_DIR', '$SIKRAKEN_INSTALL_DIR/$rel_path_c_file', '$base_name', main, debug, testcomp, '$gcc_flag', $algo])"
        $SIKRAKEN_INSTALL_DIR/eclipse/bin/x86_64_linux/eclipse -f $SIKRAKEN_INSTALL_DIR/SymbolicExecutor/se_main.pl -e "$eclipse_call"
        if [ $? -ne 0 ]; then
            echo "Sikraken regression testing ERROR: call to ECLiPSe $eclipse_call failed"
            exit 1
        else
            echo "Sikraken generated test inputs for $regression_test_file in $id configuration"
        fi

        #validate test inputs
        #testcov_output=$(testcov $testcov_data_model --no-isolation --test-suite "$SIKRAKEN_INSTALL_DIR/sikraken_output/$base_name/test-suite.zip" "$regression_test_file")
        testcov_output=$($SIKRAKEN_INSTALL_DIR/bin/run_testcov.sh $regression_test_file $testcov_data_model)
        if [ $? -ne 0 ]; then
            echo "Sikraken regression testing ERROR: TestCov test inputs validation of $regression_test_file failed"
            exit 1
        else
            echo "TestCov validated the test inputs for $regression_test_file in $id configuration"    
        fi

        tests_nb_line=$(echo "$testcov_output" | grep "Tests run:")
        test_nb_value=$(echo "$tests_nb_line" | awk '{print $3}')
        echo "Number of tests is: $test_nb_value ($expected_test_inputs_number expected)"
        coverage_line=$(echo "$testcov_output" | grep "Coverage:")
        coverage_value=$(echo "$coverage_line" | awk '{print $2}')
        coverage_value=$(echo "$coverage_value" | sed 's/%//')
        echo "Coverage is: $coverage_value ($expected_coverage expected)"

        if [ $expected_test_inputs_number != $test_nb_value ]; then
            echo "Error: Tests generation mismatch! For $regression_test_file in $id configuration, expected: $expected_test_inputs_number, but got: $test_nb_value when running: $eclipse_call." >> regression_tests_run.log
        fi

        if [ "$expected_coverage" != "$coverage_value" ]; then
            echo "Error: Coverage mismatch! For $regression_test_file in $id configuration, expected: $expected_coverage, but got: $coverage_value when running: $eclipse_call." >> regression_tests_run.log
        fi
    done
done

if [ -f regression_tests_run.log ]; then
    echo -e "\e[31mSikraken regression testing script run_regression.sh has terminated with warnings.\e[0m"
    cat regression_tests_run.log
else
    echo -e "\e[32mSikraken regression testing script run_regression.sh has terminated successfully.\e[0m"
fi