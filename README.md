# Year4ProjectSikrakenTestTool #
A Helper Tool for Sikraken, which incorporates the Genetic Algorithm to automatically find the best integer
value pair in Sikrakens regression mode. The algorithm runs sikraken/testcov (to measure coverage as our fitness)
in multiple iterations across 10 generations to find the absolute most perfect integer pair with the hisghest possible
coverage and lowest cpu time.

GeneticAlgo.py is the main algorithm file. To compare the results of the genetic algorithm I have included a simple
integer generator which create random integers for $restarts,$tries and graph the results on a scatter graph. Included 
in the repository is also a python file to generate the scatter plot from a .txt file for easier visualization of results.

---------------------------------------------------------------------------------------------------------------------------

Instruction of Use:
1.) Download Testcov from https://gitlab.com/sosy-lab/software/test-suite-validator.git into the TestCov directory
2.) Download PTC-Solver from https://github.com/echancrure/PTC-Solver/tree/C_ver (C_ver branch) into the PTC-Solver direcory
3.) Install GCC-Multilib (sudo dnf intall)
4.) Install clang-tools
