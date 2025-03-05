#include <stdio.h>
#include <assert.h>
#include "basic001.c"
int nb_of_tests = 2;

void run_test(int i) {
    switch (i) {
        case 1 : {
            int basic_4_x = 100;
            int basic_4_return = basic(basic_4_x);
            assert(basic_4_return==42);
            break;
        }
        case 2 : {
            int basic_4_x = -10;
            int basic_4_return = basic(basic_4_x);
            assert(basic_4_return==65);
            break;
        }
        default:
            assert(1);
    }
}

void main() {
    printf("Starting testing\n");
    for (int i=1; i <= nb_of_tests; i++) {
        printf("Running Test Number %d:", i);
        run_test(i);
        printf("OK\n");
    }
}