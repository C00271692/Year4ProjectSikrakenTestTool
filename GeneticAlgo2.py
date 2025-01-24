import random
import os
import time
import re
import subprocess
from typing import List, Tuple

class SikrakenOptimizer:
    def __init__(self, pop_size=10, generations=10, tournament_size=3):
        self.pop_size = pop_size # Population size
        self.generations = generations # Number of evolution cycles
        self.tournament_size = tournament_size # Number of individuals competing in selection
        self.crossover_rate = 0.7 # chance of crossover
        self.mutation_rate = 0.2 # chance of mutation


    # Create a single individual with two genes: [$restarts,$tries]
    # Each gene is an integer 1 - 50    
    def create_individual(self) -> List[int]:
        return [random.randint(1, 50), random.randint(1, 50)]
        
    def initialize_population(self) -> List[List[int]]:
        return [self.create_individual() for _ in range(self.pop_size)]

    # Evaluate fitness of individual by running Sikraken and TestCov
    # Returns coverage percentage as fitness
    def evaluate(self, individual: List[int]) -> float:
        # Run Sikraken first
        restarts, tries = individual
        sikraken_cmd = f"cd /home/kacper_k/SikrakenUserAssistTool/Sikraken && ./bin/sikraken.sh release regression[{restarts},{tries}] -m32 ./SampleCode/Problem03_label00.c"
        
        result = os.system(sikraken_cmd)
        if result != 0:
            return 0.0  # Worst fitness if Sikraken fails
            
        # Run TestCov to get coverage
        testcov_cmd = "cd /home/kacper_k/SikrakenUserAssistTool/Sikraken && ./bin/run_testcov.sh ./SampleCode/Problem03_label00.c -32"
        
        # Capture TestCov output
        try:
            output = subprocess.check_output(testcov_cmd, shell=True, text=True)
            
            # Parse coverage percentage from output
            coverage_match = re.search(r"Coverage:\s+(\d+\.?\d*)%", output)
            if coverage_match:
                coverage = float(coverage_match.group(1))
                print(f"Parameters [{restarts},{tries}] achieved {coverage}% coverage")
                return coverage
            return 0.0
        except subprocess.CalledProcessError:
            return 0.0  # Return worst fitness if TestCov fails
    
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
    random.seed(42)
    optimizer = SikrakenOptimizer(pop_size=10, generations=10)
    best_solution, best_fitness = optimizer.run()
    print(f"\nFinal best solution: {best_solution}")
    print(f"Coverage: {best_fitness}%")

if __name__ == "__main__":
    main()