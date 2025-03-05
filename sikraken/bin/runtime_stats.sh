#!/bin/bash

# Input file
INPUT_FILE="$1"

# Function to calculate statistics
calculate_stats() {
    local values=("$@")
    local count=${#values[@]}

    if [[ $count -eq 0 ]]; then
        echo "No matching values found."
        return
    fi

    local sum=0
    local min=999999
    local max=0

    for t in "${values[@]}"; do
        sum=$(echo "$sum + $t" | bc)
        (( $(echo "$t < $min" | bc -l) )) && min=$t
        (( $(echo "$t > $max" | bc -l) )) && max=$t
    done

    local average=$(echo "$sum / $count" | bc -l)

    local squared_diff_sum=0
    for t in "${values[@]}"; do
        local diff=$(echo "$t - $average" | bc -l)
        local squared_diff=$(echo "$diff^2" | bc -l)
        squared_diff_sum=$(echo "$squared_diff_sum + $squared_diff" | bc)
    done
    local std_dev=$(echo "sqrt($squared_diff_sum / $count)" | bc -l)

    echo "Count: $count"
    echo "Sum: $sum"
    echo "Average: $average"
    echo "Standard Deviation: $std_dev"
    echo "Minimum: $min"
    echo "Maximum: $max"
}

# Extract values for "Test generated" and "Using for a single test"
times_generated=($(grep -oP 'Dev Info: Test generated in \K[0-9.]+(?= seconds)' "$INPUT_FILE"))
times_single_test=($(grep -oP 'Dev Info: Using \K[0-9.]+(?= seconds for a single test)' "$INPUT_FILE"))

# Calculate and display stats for "Test generated"
echo "Statistics for 'Dev Info: Test generated in X seconds':"
calculate_stats "${times_generated[@]}"
echo

# Calculate and display stats for "Using for a single test"
echo "Statistics for 'Dev Info: Using X seconds for a single test':"
calculate_stats "${times_single_test[@]}"
