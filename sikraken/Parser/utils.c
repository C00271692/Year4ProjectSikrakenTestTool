#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "parser.h"

char* to_prolog_var(const char *input) {
    char Prolog_var_name[MAX_ID_LENGTH + 5];
    if (islower(input[0])) {  // Starts with a lowercase letter: uppercase it
        Prolog_var_name[0] = toupper(input[0]);
        strcpy_safe(&Prolog_var_name[1], MAX_ID_LENGTH - 1, &input[1]);
    } else {  // Starts with an uppercase letter: add "UC_" prefix
        strcpy_safe(Prolog_var_name, MAX_ID_LENGTH, "UC_");
        strcat_safe(Prolog_var_name, MAX_ID_LENGTH, input);
    }
    size_t size = strlen(Prolog_var_name) + 1;
    char* result = (char*)malloc(size);

    if (result != NULL) {
        strcpy_safe(result, size, Prolog_var_name);
    }
    return result;
}

void* safe_malloc(size_t size) {
    void* ptr = malloc(size);
    if (ptr == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(EXIT_FAILURE);
    }
    return ptr;
}

//todo use strdup() instead and free explicitly afterwards as usual 
void simple_str_copy(char **SS, char *S1) {
    size_t size = strlen(S1) + 1;
    *SS = (char*)malloc(size);
    strcpy_safe(*SS, size, S1);
    free(S1);
}

void simple_str_lit_copy(char **SS, const char *S1) {
    size_t size = strlen(S1) + 1;
    *SS = (char*)malloc(size);
    strcpy_safe(*SS, size, S1);
}

