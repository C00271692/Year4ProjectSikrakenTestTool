import re
import matplotlib.pyplot as plt
import mplcursors

file_path = "/home/kacper/Year4ProjectSikrakenTestTool/GAResults/Problem06GATest1.txt"

# Lists to store extracted information.
eval_numbers = []    
coverages = []       
gene_pairs = []     
evaluation_count = 0

# Regex to match lines:
pattern = re.compile(r"Gen\s+(\d+),\s+Ind\s+(\d+):\s+\[([^\]]+)\].*achieved\s+([\d\.]+)% coverage", re.IGNORECASE)

with open(file_path, "r") as f:
    for line in f:
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

# Plot the results.
plt.figure(figsize=(10, 6))
sc = plt.scatter(eval_numbers, coverages, marker='o', color='b')
plt.xlabel("Evaluation Number")
plt.ylabel("Coverage (%)")
plt.title("GA Results: ")
plt.grid(True)
plt.tight_layout()

# Attach interactive annotations that display the gene pair.
mplcursors.cursor(sc, hover=True).connect(
    "add", lambda sel: sel.annotation.set_text(f"Gene pair: [{gene_pairs[sel.index]}]")
)

plt.show()