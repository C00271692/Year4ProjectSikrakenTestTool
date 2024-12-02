#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <string.h>
#include <regex.h>


#define RESTARTS_MIN 1
#define RESTARTS_MAX 50
#define TRIES_MIN 1
#define TRIES_MAX 50
#define LOG_FILE "sikraken_output/Problem03_label00/test_run_Problem03_label00.log"

//display the log info in cmd output for users ease
void display_log_info() {
    FILE *file = fopen(LOG_FILE, "r"); //ensure log file exists (for trouble shooting)
    if (!file) {
        perror("Error opening file");
        return;
    }

    char line[1024];
    regex_t regex;
    int reti;

    // Compile the regex
    reti = regcomp(&regex, "Sikraken Session Results:|ECLiPSe CPU time:.*|Generated:.*", REG_EXTENDED); //Regex target
    if (reti) {
        fprintf(stderr, "Could not compile regex\n");
        fclose(file);
        return;
    }

    // Read the file line by line
    while (fgets(line, sizeof(line), file)) {
        // Execute the regex
        reti = regexec(&regex, line, 0, NULL, 0);
        if (!reti) {
            printf("%s", line);
        }
    }

    // Free the compiled regex
    regfree(&regex);
    fclose(file);
}


int main() {
    // Seed the random number generator
    srand(time(NULL));

    // Generate random values for restarts and tries
    int restarts = RESTARTS_MIN + rand() % (RESTARTS_MAX - RESTARTS_MIN + 1);
    int tries = TRIES_MIN + rand() % (TRIES_MAX - TRIES_MIN + 1);

    // Constructing the command
    char command[1024];
    snprintf(command, sizeof(command),
             "./bin/sikraken.sh release regression[%d,%d] -m32 ./SampleCode/Problem03_label00.c",
             restarts, tries);

    // Print the command for debugging purposes
    printf("Running command: %s\n", command);

    // Change to the SikrakenUserAssistTool directory
    if (chdir("/home/kacper_k/SikrakenUserAssistTool/Sikraken") != 0) {
        perror("Error changing directory");
        return EXIT_FAILURE;
    }

    // Execute the command
    int result = system(command);

    // Check the result of the command execution
    if (result == -1) {
        perror("Error executing command");
        return EXIT_FAILURE;
    }

    // Display the specific log information
    display_log_info();

    return EXIT_SUCCESS;
}