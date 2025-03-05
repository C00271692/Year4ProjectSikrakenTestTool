extern int __VERIFIER_nondet_int();
int main() {
    unsigned int us = 0 - 5; // underflow occurs here during assignment
    if (us == 4294967291 + __VERIFIER_nondet_int()) ;  // input should 0
    else ;                   // any value different than 0 is fine
    int s = 5 + 2147483647; // overflow occurs here during evaluation of intermediate expression (and during assignment by default)
//    if (s == -2147483644) ; // should always be true
//    else ;                  // dead code
//    s = -5 - 2147483648;    // underflow occurs here during evaluation of intermediate expression (and during assignment by default)
//    if (s == 2147483643) ;  // should always be true
//    else ;                  // dead code
    s = 2147483647 + __VERIFIER_nondet_int();
    if (s == -2147483644) ; // overflow necessary i.e. input must be 5 
    else ;                  // any negative value is fine or different than 5
//    s = -2147483647 + __VERIFIER_nondet_int();
//    if (s == 2147483644) ;  // underflow necessary i.e. input must be -5
//    else ;                  // any positive value is fine or different than -5
//    s = 42 + __VERIFIER_nondet_int();
//    if (s == 42) ;          // no overflow necessary input == 0
//    else ;                  // any value different than 0 is fine 
    return s;
}