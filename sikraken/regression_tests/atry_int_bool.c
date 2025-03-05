extern void exit(int);
extern int __VERIFIER_nondet_int();
extern float __VERIFIER_nondet_float();
extern unsigned char __VERIFIER_nondet_uchar();
int main() {
    unsigned char c = __VERIFIER_nondet_uchar();
    int var_1_10 = __VERIFIER_nondet_int();
    if (var_1_10) ;     
    else ;          //labeling of var_1_10 will cause overflow if it has a hole in its domain (e.g. 0 here) and has a large domain (e.g. is an int)
}