import random
import os
import time
import re
import subprocess
import concurrent.futures
import threading
import datetime
import sys
from typing import List, Tuple
import glob

class SikrakenOptimizer:
    def __init__(self, pop_size=10, generations=10, tournament_size=3, target_file=None, 
                 max_retries=3, debug=False, base_directory="", restart_range=None, tries_range=None):
        self.pop_size = pop_size # Population size
        self.generations = generations # Number of evolution cycles
        self.tournament_size = tournament_size # Number of individuals competing in selection
        self.crossover_rate = 0.85 # chance of crossover
        self.mutation_rate = 0.15 # chance of mutation
        self.target_file = target_file
        self.max_retries = max_retries
        self.debug = debug
        self.base_dir = base_directory
        # Add lock for TestCov runs
        self.testcov_lock = threading.Lock()
        # Parameter ranges
        self.restart_range = restart_range or (1, 500)
        self.tries_range = tries_range or (1, 500)
        # For result collection
        self.result_lines = []

    @staticmethod
    def list_sample_files(base_dir: str = "") -> List[str]:
        # Get all .c files only from directory
        sample_dir = base_dir + "/regression_tests"
        c_files = glob.glob(f"{sample_dir}/*.c")
        return [os.path.basename(f) for f in c_files]
    

    # Create a single individual with two genes: [$restarts,$tries]    
    def create_individual(self) -> List[int]:
        return [random.randint(*self.restart_range), random.randint(*self.tries_range)]
        
    def initialize_population(self) -> List[List[int]]:
        return [self.create_individual() for _ in range(self.pop_size)]


    def halve_parameters(self, individual: List[int]) -> List[int]:
        """Halve both parameters if timeout occurs"""
        return [max(1, x // 2) for x in individual]
        
    # Evaluate fitness of individual by running Sikraken and TestCov
    # Returns coverage percentage as fitness
    def evaluate(self, individual: List[int], gen_num: int = 0, ind_num: int = 0) -> float:
        if not self.target_file:
            return 0.0
            
        current_individual = individual.copy()
        attempts = 0
        max_attempts = 5  # Prevent infinite halving
        
        while attempts < max_attempts:
            restarts, tries = current_individual
            start_time = time.time()
            
            try:
                # Run Sikraken (this can run in parallel)
                sikraken_cmd = f"cd {self.base_dir} && ./bin/sikraken.sh release regression[{restarts},{tries}] -m32 ./regression_tests/{self.target_file}"
                result = subprocess.run(sikraken_cmd, shell=True, capture_output=True, text=True, timeout=90)
                
                if result.returncode == 0:
                    # Run TestCov with a lock to prevent concurrent runs
                    with self.testcov_lock:
                        testcov_cmd = f"cd {self.base_dir} && ./bin/run_testcov.sh ./regression_tests/{self.target_file} -32"
                        cov_result = subprocess.run(testcov_cmd, shell=True, capture_output=True, text=True, timeout=60)
                    
                    elapsed_time = time.time() - start_time
                    
                    if cov_result.returncode == 0:
                        coverage_match = re.search(r"Coverage:\s+(\d+\.?\d*)%", cov_result.stdout)
                        if coverage_match:
                            coverage = float(coverage_match.group(1))
                            result_line = f"Gen {gen_num}, Ind {ind_num}: [{restarts},{tries}] achieved {coverage:.2f}% coverage in {elapsed_time:.2f}s"
                            print(result_line)
                            # Store the result line for later saving to file
                            self.result_lines.append(result_line)
                            return coverage
                
                print(f"Gen {gen_num}, Ind {ind_num}: [{restarts},{tries}] failed")
                self.result_lines.append(f"Gen {gen_num}, Ind {ind_num}: [{restarts},{tries}] failed")
                return 0.0

            except subprocess.TimeoutExpired:
                timeout_msg = f"Gen {gen_num}, Ind {ind_num}: [{restarts},{tries}] timed out, halving values..."
                print(timeout_msg)
                self.result_lines.append(timeout_msg)
                current_individual = self.halve_parameters(current_individual)
                attempts += 1
                
        fail_msg = f"Gen {gen_num}, Ind {ind_num}: Failed after {attempts} halving attempts"
        print(fail_msg)
        self.result_lines.append(fail_msg)
        return 0.0

    # Tournament selection: randomly select tournament_size individuals
    # Return the one with best fitness (highest coverage)    
    def tournament_select(self, population: List[List[int]], fitnesses: List[float]) -> List[int]:
        tournament = random.sample(list(zip(population, fitnesses)), self.tournament_size)
        return max(tournament, key=lambda x: x[1])[0]
    
    # Single point crossover between two parents
    # crossover_rate chance of crossover occurring    
    def crossover(self, parent1: List[int], parent2: List[int]) -> Tuple[List[int], List[int]]:
        # Crossover with probability self.crossover_rate
        if random.random() > self.crossover_rate:
            # No crossover - return copies of parents
            return parent1.copy(), parent2.copy()

        # Randomly select crossover point and swap genes    
        point = random.randint(1, len(parent1) - 1)
        child1 = parent1[:point] + parent2[point:]
        child2 = parent2[:point] + parent1[point:]
        return child1, child2
        
    def mutate(self, individual: List[int]) -> List[int]:
        # Create a copy to avoid modifying the original
        result = individual.copy()
        # Random mutation of genes
        # mutation_rate chance per gene of being randomized
        if random.random() < self.mutation_rate:
            result[0] = random.randint(*self.restart_range)
        if random.random() < self.mutation_rate:
            result[1] = random.randint(*self.tries_range)
        return result
        
    # Main genetic algo loop with parallel evaluation
    def run(self):
        population = self.initialize_population()
        best_solution = None
        best_fitness = 0.0
        
        # Clear previous results
        self.result_lines = []
        
        # Determine optimal number of workers based on CPU cores
        max_workers = min(self.pop_size, (os.cpu_count() or 4))
        print(f"Using {max_workers} worker threads for parallel evaluation")
        
        for gen in range(self.generations):
            print(f"\nGeneration {gen + 1}/{self.generations}")
            
            # Prepare evaluation tasks
            eval_tasks = [(ind, gen + 1, i + 1) for i, ind in enumerate(population)]
            
            # Evaluate population in parallel
            fitnesses = [0.0] * len(population)  # Initialize fitness list
            
            with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
                # Submit all evaluation tasks
                future_to_idx = {}
                for i, (ind, gen_num, ind_num) in enumerate(eval_tasks):
                    future = executor.submit(self.evaluate, ind, gen_num, ind_num)
                    future_to_idx[future] = i
                
                # Collect results as they complete
                for future in concurrent.futures.as_completed(future_to_idx):
                    idx = future_to_idx[future]
                    try:
                        fitnesses[idx] = future.result()
                    except Exception as exc:
                        print(f"Evaluation {idx} generated an exception: {exc}")
                        fitnesses[idx] = 0.0
            
            # Track best solution
            for ind, fit in zip(population, fitnesses):
                if fit > best_fitness:
                    best_solution = ind.copy()
                    best_fitness = fit
                    
            # Create new population
            new_population = []
            while len(new_population) < self.pop_size:
                parent1 = self.tournament_select(population, fitnesses)
                parent2 = self.tournament_select(population, fitnesses)
                child1, child2 = self.crossover(parent1, parent2)
                new_population.extend([self.mutate(child1), self.mutate(child2)])
                
            population = new_population[:self.pop_size]
            best_msg = f"Best solution so far: {best_solution} with coverage: {best_fitness}%"
            print(best_msg)
            self.result_lines.append(best_msg)
            
        # Add final best solution to results
        self.result_lines.append(f"\nFinal Best Solution: {best_solution}")
        self.result_lines.append(f"Final Coverage: {best_fitness}%")
        
        return best_solution, best_fitness

    def save_results(self):
        # Create GAResults directory if it doesn't exist
        if not os.path.exists("GAResults"):
            os.makedirs("GAResults")
            
        # Create a timestamp for the filename
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"GAResults/{os.path.splitext(self.target_file)[0]}_{timestamp}.txt"
        
        with open(filename, "w") as f:
            # Write header information
            f.write(f"# Genetic Algorithm Results for {self.target_file}\n")
            f.write(f"# Date: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"# Parameter ranges: restarts ({self.restart_range[0]}-{self.restart_range[1]}), tries ({self.tries_range[0]}-{self.tries_range[1]})\n")
            f.write(f"# Population size: {self.pop_size}, Generations: {self.generations}\n\n")
            
            # Write all result lines
            for line in self.result_lines:
                f.write(f"{line}\n")
                
        return filename

def main():
    base_dir = input("Enter the base directory of Sikraken: ")

    # List available C files
    available_files = SikrakenOptimizer.list_sample_files(base_dir)
        
    print("\nAvailable C files:")
    for i, file in enumerate(available_files, 1):
        print(f"{i}. {file}")
        
    # Get user selection (with some basic validation)
    while True:
        try:
            selection = int(input("\nSelect file number to analyze: ")) - 1
            if 0 <= selection < len(available_files):
                target_file = available_files[selection]
                print(f"\nSelected file: {target_file}")
                break
            print("Invalid selection. Please try again.")
        except ValueError:
            print("Please enter a number.")

    # Get parameter ranges from user (with basic validation)
    print("\nSet parameter ranges:")
    
    # Get restart_min with proper validation
    while True:
        try:
            restart_min = int(input("Minimum $restart value: "))
            if restart_min < 1:
                print("Invalid input. Value must be at least 1. Try again.")
                continue
            break
        except ValueError:
            print("Invalid input. Please enter a number.")
    
    # Get restart_max with proper validation
    while True:
        try:
            restart_max = int(input("Maximum $restart value: "))
            if restart_max < restart_min:
                print(f"Invalid input. Value must be at least {restart_min}. Try again.")
                continue
            break
        except ValueError:
            print("Invalid input. Please enter a number.")
    
    # Get tries_min with proper validation
    while True:
        try:
            tries_min = int(input("Minimum $tries value: "))
            if tries_min < 1:
                print("Invalid input. Value must be at least 1. Try again.")
                continue
            break
        except ValueError:
            print("Invalid input. Please enter a number.")
    
    # Get tries_max with proper validation
    while True:
        try:
            tries_max = int(input("Maximum $tries value: "))
            if tries_max < tries_min:
                print(f"Invalid input. Value must be at least {tries_min}. Try again.")
                continue
            break
        except ValueError:
            print("Invalid input. Please enter a number.")
    
    # Run optimizer with selected file and parameter ranges
    random.seed(42)  # !!!REMOVE SEED WHEN DONE TESTING!!!
    optimizer = SikrakenOptimizer(
        pop_size=10, 
        generations=10, 
        target_file=target_file, 
        max_retries=3, 
        base_directory=base_dir,
        restart_range=(restart_min, restart_max),
        tries_range=(tries_min, tries_max)
    )
    
    best_solution, best_fitness = optimizer.run()
    print(f"\nBest solution for {target_file}: {best_solution}")
    print(f"Coverage: {best_fitness}%")
    
    # Save results to file
    results_file = optimizer.save_results()
    print(f"Results saved to: {results_file}")
    
    # Ask if user wants to see the graph
    show_graph = input("\nWould you like to see the results graph? (y/n): ").lower().strip()
    if show_graph == 'y' or show_graph == 'yes':
        try:
            subprocess.run([sys.executable, "InteractiveGraphPlot.py", results_file])
        except Exception as e:
            print(f"Error displaying graph: {e}")
            print("You can view the graph later by running: python InteractiveGraphPlot.py {results_file}")

if __name__ == "__main__":
    main()