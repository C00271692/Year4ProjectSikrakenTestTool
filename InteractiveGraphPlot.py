import re
import matplotlib.pyplot as plt
import mplcursors
import sys
import os

def plot_results(file_path):
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        return
        
    print(f"Analyzing file: {file_path}")
    
    # Lists to store extracted information
    eval_numbers = []    
    coverages = []       
    gene_pairs = []     
    evaluation_count = 0
    
    # Regex to match lines with coverage results
    pattern = re.compile(r"Gen\s+(\d+),\s+Ind\s+(\d+):\s+\[([^\]]+)\].*achieved\s+([\d\.]+)% coverage", re.IGNORECASE)
    
    # Extract file metadata
    metadata = {}
    with open(file_path, "r") as f:
        for line in f:
            if line.startswith("#"):
                if ":" in line:
                    key, value = line[1:].strip().split(":", 1)
                    metadata[key.strip()] = value.strip()
            else:
                match = pattern.search(line)
                if match:
                    evaluation_count += 1
                    # gen = match.group(1)
                    # ind = match.group(2)
                    gp = match.group(3)  
                    cov = float(match.group(4))
                    eval_numbers.append(evaluation_count)
                    coverages.append(cov)
                    gene_pairs.append(gp)
    
    if not eval_numbers:
        print("No matching data found in the file. Check if the file format is correct.")
        return
    
    # Find best coverage point
    best_idx = coverages.index(max(coverages)) if coverages else -1
    
    # Plot the results
    plt.figure(figsize=(10, 6))
    sc = plt.scatter(eval_numbers, coverages, marker='o', color='b')
    
    # Add title information from metadata if available
    title = "GA Results: "
    if "Genetic Algorithm Results for" in metadata:
        title += metadata["Genetic Algorithm Results for"]
    else:
        title += os.path.basename(file_path)
    
    plt.xlabel("Evaluation Number")
    plt.ylabel("Coverage (%)")
    plt.title(title)
    plt.grid(True)
    
    # Highlight the best solution
    if best_idx >= 0:
        best_x = eval_numbers[best_idx]
        best_y = coverages[best_idx]
        best_gp = gene_pairs[best_idx]
        plt.scatter([best_x], [best_y], marker='*', color='r', s=200, 
                   label=f"Best: [{best_gp}] - {best_y:.2f}%")
        plt.legend()
    
    plt.tight_layout()
    
    # Attach interactive annotations that display the gene pair on hover
    mplcursors.cursor(sc, hover=True).connect(
        "add", lambda sel: sel.annotation.set_text(f"Gene pair: [{gene_pairs[sel.index]}]")
    )
    
    # Display parameter range info if available
    if "Parameter ranges" in metadata:
        plt.figtext(0.5, 0.01, metadata["Parameter ranges"], 
                   ha="center", fontsize=9, bbox={"facecolor":"orange", "alpha":0.1, "pad":5})
    
    plt.show()

if __name__ == "__main__":
    # Check if file path is provided as argument
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
    else:
        # If no file provided, ask user to input it
        file_path = input("Enter the path to the results file: ")
    
    plot_results(file_path)