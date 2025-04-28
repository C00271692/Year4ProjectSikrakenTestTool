# Year4ProjectSikrakenTestTool #
A Helper Tool for Sikraken, which incorporates the Genetic Algorithm to automatically find the best integer
value pair in Sikrakens regression mode. The algorithm runs sikraken/testcov (to measure coverage as our fitness)
in multiple iterations across 10 generations to find the absolute most perfect integer pair with the highest possible
coverage and lowest cpu time.

GeneticAlgo2.py is the main algorithm file. To compare the results of the genetic algorithm I have included a simple
integer generator (RandomIntPairs.py) which create random integers for $restarts,$tries and graph the results on a scatter graph. Included 
in the repository is also a python file to generate the scatter plot from a .txt file for easier visualization of results (InteraciveGraphPlot.py),
which is now also integrated into the main algorithm file for ease of use.

Please note: this project is designed to run on a Linux environment only!

---------------------------------------------------------------------------------------------------------------------------

Instruction of Use:

1.) Download Testcov from https://gitlab.com/sosy-lab/software/test-suite-validator.git and paste it into where the TestCov directory placeholder is 

2.) Download PTC-Solver from https://github.com/echancrure/PTC-Solver/tree/C_ver (C_ver branch) and paste it into where the PTC-Solver direcory placeholder is

3.) Install GCC-Multilib (sudo dnf install)

4.) Install clang-tools

5.) Run the desireed algorithm/randomizer and see results

6.) Your directory structure inside of Year4ProjectSikrakenTestTool should be something like this:

GeneticAlgo2.py
InteractiveGraphPlot.py
\GAResults
\ProjDocs
...
        \sikraken
        	\bin
        	call_parser.sh
        	compile_parser.sh
        	run_regression.sh
        	run_testcov.sh
                sikraken_parser.exe
                sikraken.sh
                version.txt
        		...
          \TestCov
            \build
            \bin
            \suite_validation
            ...
        	\Documentation
        		Development Log.gdoc
        		README.md
                        Sikraken Development Guide.gdoc
                        ...	
        \eclipse
        		...
        	\Parser
        		C_grammar.l
        		C_grammar.y
                        ...
        \PTC-Solver
        	\doc
        	\source
        	README.md
        	...
        	\RegressionTests	
        		foo.c
        		foo.json
        		foo.yml
        ...
        	\SampleCode
        		foo.c
        		simple_if.c
        ...
        \sikraken_output
        	...
        	\SymbolicExecutor
        		se_main.pl
        		...
        	.gitignore
        	.gitmodules
        	LICENSE
        	README.md

 
