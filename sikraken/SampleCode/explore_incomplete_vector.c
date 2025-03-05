extern int __VERIFIER_nondet_int();
int main() {
    int x = __VERIFIER_nondet_int();
    if (x > 5) {
        x = x + 1;
    } else {
        x = x - 1;
    }
    int y = __VERIFIER_nondet_int();    //remove one of the input for y and see if x still gets covered for negative by TestCov
    if (y > 5) {
        y = y + 1;
    } else {
        y = y - 1;
    }
    return 0;
}