#!/bin/bash

# Ensure script is passed an argument
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <relative_or_absolute_path_to_timestamp_directory> <budget> <mode>"
    exit 1
fi

# Convert relative path to absolute path
input_dir=$(realpath "$1")
budget=$2
mode=$3
category=$(basename "$(dirname "$input_dir")")
timestamp=$(basename "$input_dir")
output_file="${input_dir}/category_test_run_results.html"

# Path to benchmark_files.txt
benchmark_file_mapping="${input_dir}/benchmark_files.txt"

# Ensure benchmark_files.txt exists
if [ ! -f "$benchmark_file_mapping" ]; then
    echo "Error: File 'benchmark_files.txt' not found. Exiting."
    exit 1
fi

total_coverage=0
rows=""

# Process benchmarks in the order listed in benchmark_files.txt
while IFS= read -r line; do
    # Extract file path and benchmark name
    file_path=$(echo "$line" | awk '{print $1}')  # Extract full path
    benchmark_name=$(basename "$file_path")       # Extract filename with extension
    benchmark_base=$(basename "$file_path" .c)   # Strip .c extension (if any)
    benchmark_base=$(basename "$benchmark_base" .i) # Strip .i extension (if any)

    benchmark_dir="${input_dir}/${benchmark_base}"
    
    plot_file="${benchmark_dir}/sikraken_plot.png"
    log_file="${benchmark_dir}/testcov/testcov_call.log"
    sikraken_log="${benchmark_dir}/sikraken.log"
    test_run_log="./sikraken_output/${benchmark_base}/test_run_${benchmark_base}.log"


    # Ensure benchmark directory exists
    if [ ! -d "$benchmark_dir" ]; then
        echo "Directory for benchmark $benchmark_base not found, skipping."
        continue
    fi

    # Verify log file existence
    if [ ! -f "$log_file" ]; then
        echo "Log file not found: $log_file"
        continue
    fi

    # Extract information
    test_count=$(grep -oP "Tests in suite:\s+\K\d+" "${log_file}" 2>/dev/null || echo "N/A")
    coverage=$(grep -oP "Coverage:\s+\K[\d.]+(?=%)" "${log_file}" 2>/dev/null || echo "0")
    stack_peak=$(grep -oP "global_stack_peak:\s+\K\d+" "$test_run_log" 2>/dev/null || echo "0")
    stack_peak_mb=$(bc <<< "scale=2; $stack_peak / 1048576")

    # Sum coverage for the total
    total_coverage=$(bc <<< "$total_coverage + $coverage")

    # Highlight rows with 0 tests in light red
    if [ "$test_count" == "0" ] || [ "$test_count" == "N/A" ]; then
        row_class="style='background-color: lightcoral;'"
    else
        row_class=""
    fi

    # Add link to code
    code_link="<a href=\"file://${file_path}\" target=\"_blank\">${benchmark_name}</a>"
    sikraken_log_link="<a href=\"file://${sikraken_log}\" target=\"_blank\">Sikraken Log</a>"
    testcov_log_link="<a href=\"file://${log_file}\" target=\"_blank\">TestCov Log</a>"
    # Add row to table
    rows+="<tr $row_class>
        <td>${code_link}</td>
        <td>${sikraken_log_link}</td>
        <td>${test_count}</td>
        <td>${coverage}%</td>
        <td>${testcov_log_link}</td>
        <td><a href=\"${plot_file}\" target=\"_blank\"><img src=\"${plot_file}\" style=\"max-width: 150px; max-height: 100px;\"></a></td>
        <td>${stack_peak_mb} MB</td>
    </tr>"
done < "$benchmark_file_mapping"

# Calculate total coverage
total_score=$(bc <<< "scale=2; $total_coverage / 100")

# Generate HTML
cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${category} Test Run Results</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>${category} - ${timestamp}</h1>
    <h2>Budget: ${budget} seconds</h2>
    <h2>Mode: ${mode}</h2>
    <h2>Number of Benchmarks: $(wc -l < "$benchmark_file_mapping")</h2>
    <h2>Overall Score Achieved: ${total_score}</h2>
    <table>
        <thead>
            <tr>
                <th>Benchmark</th>
                <th>Sikraken Log</th>
                <th>TestCov Number of Tests</th>
                <th>Coverage Achieved</th>
                <th>TestCov Log</th>
                <th>Graph</th>
                <th>Peak Global Stack (MB)</th>
            </tr>
        </thead>
        <tbody>
            ${rows}
        </tbody>
    </table>
</body>
</html>
EOF

echo "HTML report generated: $output_file"
