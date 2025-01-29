import random
import os
import time
import re
import subprocess
from typing import List, Tuple
import glob

class SikrakenOptimizer:
    def __init__(self, pop_size=10, generations=10, tournament_size=3, target_file=None, max_retries=3, debug=False):
        self.pop_size = pop_size # Population size
        self.generations = generations # Number of evolution cycles
        self.tournament_size = tournament_size # Number of individuals competing in selection
        self.crossover_rate = 0.7 # chance of crossover
        self.mutation_rate = 0.2 # chance of mutation
        self.target_file = target_file
        self.max_retries = max_retries
        self.debug = debug
        self.base_dir = "/home/kacper_k/SikrakenUserAssistTool/Sikraken"

    @staticmethod
    def list_sample_files():
        # Get all .c files from SampleCode directory
        sample_dir = "/home/kacper_k/SikrakenUserAssistTool/Sikraken/regression_tests"
        c_files = glob.glob(f"{sample_dir}/*.c")
        return [os.path.basename(f) for f in c_files]
    

    # Create a single individual with two genes: [$restarts,$tries]
    # Each gene is an integer 1 - 50    
    def create_individual(self) -> List[int]:
        return [random.randint(1, 50), random.randint(1, 50)]
        
    def initialize_population(self) -> List[List[int]]:
        return [self.create_individual() for _ in range(self.pop_size)]

    def validate_paths(self):
        if not os.path.exists(self.base_dir):
            raise ValueError(f"Sikraken directory not found: {self.base_dir}")
        if not os.path.exists(f"{self.base_dir}/regression_tests/{self.target_file}"):
            raise ValueError(f"Target file not found: {self.target_file}")

    # Evaluate fitness of individual by running Sikraken and TestCov
    # Returns coverage percentage as fitness
    def evaluate(self, individual: List[int]) -> float:
        if not self.target_file:
            return 0.0
            
        restarts, tries = individual
        retries = 0
        
        # Run Sikraken and TestCov
        # Perfiorming error handling and retries
        while retries < self.max_retries:
            try:
                # Run Sikraken with timeout
                sikraken_cmd = f"cd {self.base_dir} && ./bin/sikraken.sh release regression[{restarts},{tries}] -m32 ./regression_tests/{self.target_file}"
                result = subprocess.run(sikraken_cmd, shell=True, capture_output=True, text=True, timeout=300)
                
                if result.returncode != 0:
                    print(f"Attempt {retries + 1}: Sikraken failed with error: {result.stderr}")
                    retries += 1
                    continue
                    
                # Run TestCov
                testcov_cmd = f"cd {self.base_dir} && ./bin/run_testcov.sh ./regression_tests/{self.target_file} -32"
                cov_result = subprocess.run(testcov_cmd, shell=True, capture_output=True, text=True, timeout=60)
                
                if cov_result.returncode == 0:
                    coverage_match = re.search(r"Coverage:\s+(\d+\.?\d*)%", cov_result.stdout)
                    if coverage_match:
                        coverage = float(coverage_match.group(1))
                        print(f"Parameters [{restarts},{tries}] achieved {coverage}% coverage")
                        return coverage
                        
                retries += 1
                
            except subprocess.TimeoutExpired:
                print(f"Attempt {retries + 1}: Timeout")
                retries += 1
            except Exception as e:
                print(f"Attempt {retries + 1}: Unexpected error: {str(e)}")
                retries += 1
                
        print(f"All {self.max_retries} attempts failed for parameters [{restarts},{tries}]")
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
        # Random mutation of genes
        # mutation_rate chance per gene of being randomized
        for i in range(len(individual)):
            if random.random() < self.mutation_rate:
                individual[i] = random.randint(1, 50)
        return individual
        
    # Main genetic algo loop
    def run(self):
        population = self.initialize_population()
        best_solution = None
        best_fitness = 0.0
        
        for gen in range(self.generations):
            print(f"\nGeneration {gen + 1}/{self.generations}")
            
            # Evaluate population
            fitnesses = [self.evaluate(ind) for ind in population]
            
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
            print(f"Best solution so far: {best_solution} with coverage: {best_fitness}%")
            
        return best_solution, best_fitness

def main():
    # List available C files
    available_files = SikrakenOptimizer.list_sample_files()
    if not available_files:
        print("No C files found in the directory")
        return
        
    print("\nAvailable C files:")
    for i, file in enumerate(available_files, 1):
        print(f"{i}. {file}")
        
    # Get user selection with validation
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
            
    # Run optimizer with selected file
    random.seed(42)
    optimizer = SikrakenOptimizer(pop_size=10, generations=10, target_file=target_file, max_retries=3)
    best_solution, best_fitness = optimizer.run()
    print(f"\nBest solution for {target_file}: {best_solution}")
    print(f"Coverage: {best_fitness}%")

if __name__ == "__main__":
    main()