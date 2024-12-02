# Year4ProjectSikrakenTestTool
A Helper Tool for Sikraken to make it more user friendly

2/12/2024:
Added Cpu time and number of tests generated from test_run_Problem03_label00.log file, using regex to isolate the relevant values and displaying
them in the termianl output

2/12/2024:
First commit, very basic C script that will insert 2 random integers (for Regression mode) ./bin/sikraken.sh release regression[$restarts,$tries]
The script will run Sikraken and output a success/fail message.
Currently problem03 is hardcoded, so no way switching C code samples yet 
