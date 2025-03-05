// compile via:                 gcc -fprofile-arcs -ftest-coverage gcov_example.c -o gcov_example
// run the executable produced: ./gcov_example
// generate the gcov report:    gcov -b gcov_example.c
// gcov report:
//      File 'gcov_example.c'
//      Lines executed:100.00% of 8
//      Branches executed:100.00% of 2
//      Taken at least once:100.00% of 2
//      Calls executed:100.00% of 2
//      Creating 'gcov_example.c.gcov'
//      
//      Lines executed:100.00% of 8     
#include <stdio.h>

int is_positive(int x) {
    if (x > 0) {          // Branch 1: (x > 0)
        return 1;
    } else {
        return 0;
    }
}

int main() {
    int a = is_positive(5);   // First call to is_positive
    int b = is_positive(-3);  // Second call to is_positive
    return 0;
}