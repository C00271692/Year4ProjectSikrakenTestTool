#!/bin/bash

rel_path_c_file="$1"                    #e.g. ./../SampleCode/atry_bitwise.c or .i
testcov_data_model="$2"

file_name_no_ext="${rel_path_c_file%.*}"
base_name=$(basename "$file_name_no_ext")

zipfile="./sikraken_output/$base_name/test-suite.zip"
rm -f $zipfile
zip -r $zipfile "./sikraken_output/$base_name/test-suite"
testcov_call="testcov $testcov_data_model --test-suite $zipfile $rel_path_c_file --output "./sikraken_output/$base_name/testcov" --reduction NONE --no-runexec --no-isolation --no-plots"
echo "CALL TO TESTCOV IS $testcov_call"
$testcov_call
if [ $? -ne 0 ]; then
    echo "ERROR: TestCov validation failed for $rel_path_c_file"
    exit 1
fi