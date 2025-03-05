extern void exit(int);
extern int __VERIFIER_nondet_int();

int main() {
    // 1. Implicit conversion (integer promotion)
    char c = 120;
    int i = c;  // char promoted to int
    if (i != 120) exit(1);
    // 2. Implicit conversion (int to float)
    int x = 42;
    float f = x;  // int converted to float
    if (f != 42.0) exit(1);
    // 3. Explicit conversion (float to int)
    float pi = 3.14;
    int truncated = (int)pi;  // float truncated to int
    if (truncated != 3) exit(1);
    unsigned int ui = - 8u;
    if (ui != 4294967288) exit(1);
    int tale = __VERIFIER_nondet_int();
    if (tale > 42) ;
    else ;
}