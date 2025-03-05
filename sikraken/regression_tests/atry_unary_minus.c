//#include <stdio.h>
extern int __VERIFIER_nondet_int();
int main() {
    int i = -5;             // -5
    unsigned int ui = -5;   // 4294967291
    char c = -5;            // -5
    unsigned char uc = -5;  // 251
    short s = -5;           // -5       
    unsigned short us = -5; // 65531
    long l = -5;            //-5    
    unsigned long ul = -5;  // 4294967291
    long long ll = -5;      //-5
    //sikraken cannot handle very large numbers so we comment out the following lines
    //unsigned long long ull = -5;    // 18446744073709551611 [total is 65742]
    //printf("i + ui + c + uc + s + us + l + ul + ll + ull: %llu\n", i + ui + c + uc + s + us + l + ul + ll + ull);    
    float f = -5;           // -5.0
    double d = -5;          // -5.0 
    long double ld = -5;    // -5.0
    long long total = i + ui + c + uc + s + us + l + ul + ll + f + d + ld;    // 65732
    if (total == __VERIFIER_nondet_int()) {
       return 0;
    } else ;
    /*
    printf("int i: %d\n", i);
    printf("unsigned int ui: %u\n", ui);
    printf("char c: %d\n", c); // Printed as int to show its numerical value
    printf("unsigned char uc: %u\n", uc); // Printed as unsigned int
    printf("short s: %hd\n", s);
    printf("unsigned short us: %hu\n", us);
    printf("long l: %ld\n", l);
    printf("unsigned long ul: %lu\n", ul);
    printf("long long ll: %lld\n", ll);
    printf("unsigned long long ull: %llu\n", ull);
    printf("float f: %f\n", f);
    printf("double d: %lf\n", d); // Use %lf for double in printf
    printf("long double ld: %Lf\n", ld);
    printf("long long total: %lld\n", total);
    */
    return 0;
}