#include <stdarg.h>
#include <stdio.h>

void print_value(void *data, char type) {
}

void process_args(int num_args, ...) {
    va_list args;
    va_start(args, num_args);

    for (int i = 0; i < num_args; i++) {
        // Retrieve a void ** argument
        void **arg = __builtin_va_arg(args, void **);
        printf("Argument %d: %p\n", i + 1, *arg);
    }

    va_end(args);
}

int main() {
    
    void *ptr1 = (void *)0x1234;
    void *ptr2 = (void *)0x5678;

    process_args(2, &ptr1, &ptr2);

    return 0;
}
