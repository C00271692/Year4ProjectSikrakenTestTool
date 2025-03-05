extern int __VERIFIER_nondet_int();
int main() {
    int x = __VERIFIER_nondet_int();
    if (x != 1 && x != 2 && x != 3) {
        x = x + 1;
    } else {
        x = x - 1;
    }
    return 0;
}