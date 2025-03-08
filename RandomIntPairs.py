import random
import subprocess
import re
import matplotlib.pyplot as plt
import mplcursors  # for interactive annotations

base_dir = "/home/kacper/Year4ProjectSikrakenTestTool/sikraken"
target_file = "Problem03_label00.c"
random.seed(42)

def evaluate_individual(individual):
    restarts, tries = individual

    sikraken_cmd = (
        f"cd {base_dir} && ./bin/sikraken.sh release regression[{restarts},{tries}] -m32 "
        f"./regression_tests/{target_file}"
    )
    print("Running:", sikraken_cmd)
    subprocess.run(sikraken_cmd, shell=True)

    testcov_cmd = f"cd {base_dir} && ./bin/run_testcov.sh ./regression_tests/{target_file} -32"
    print("Running:", testcov_cmd)
    output = subprocess.check_output(testcov_cmd, shell=True, universal_newlines=True)
    
    m = re.search(r"Coverage:\s+(\d+\.?\d*)%", output)
    if m:
        return float(m.group(1))
    return 0.0

def main():
    n_tests = 100
    fitnesses = []
    gene_pairs = []

    for i in range(n_tests):
        individual = [random.randint(1, 500), random.randint(1, 500)]
        gene_pairs.append(individual)
        print(f"\nTest {i+1} with gene pair: {individual}")
        fitness = evaluate_individual(individual)
        fitnesses.append(fitness)
        print(f"Test {i+1} fitness: {fitness}%")
    
    plt.figure(figsize=(10, 6))
    sc = plt.scatter(range(1, n_tests+1), fitnesses, marker='o', color='b')
    plt.xlabel("Test Number")
    plt.ylabel("Coverage (%)")
    plt.title("Coverage of 100 Random Individuals")
    plt.grid(True)
    plt.tight_layout()
    
    mplcursors.cursor(sc, hover=True).connect(
        "add", lambda sel: sel.annotation.set_text(f"Gene pair: {gene_pairs[sel.index]}")
    )
    
    plt.show()

if __name__ == "__main__":
    main()