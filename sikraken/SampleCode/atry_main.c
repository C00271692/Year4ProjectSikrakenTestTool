//#include <stdio.h>
extern unsigned long __VERIFIER_nondet_ulong();
extern int __VERIFIER_nondet_int(void);
int main(int argc, char **argv) {
    int i = __VERIFIER_nondet_int();
    if (i<0) i++;
    else i++;
    /*printf("Number of arguments (argc): %d\n", argc);

    for (int i = 0; i < argc; i++) {
        printf("argv[%d]: %s\n", i, argv[i]);
    }
    */
    return i;
}