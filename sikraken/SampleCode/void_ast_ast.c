#include <stdarg.h>
#include <stdio.h>

void example_function(int num, ...) {
    va_list args;
    va_start(args, num);
    
    void **ptr = __builtin_va_arg(args, void **);
    
    va_end(args);
    
    printf("Retrieved pointer address: %p\n", *ptr);
}

int main() {
    int value = 42;
    int *ptr = &value;
    
    example_function(1, &ptr);
    
    return 0;
}
