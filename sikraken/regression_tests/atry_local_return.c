extern int __VERIFIER_nondet_int();

int fn(int x) {
    int z = x+1;
    return z;
}


int main() {
    int b = fn(42);
    int i = 0;
    if (b == __VERIFIER_nondet_int()) i-- ;
    else i++;
    int x = fn(b);      //43
    if (x == __VERIFIER_nondet_int()) i--;
    else i++;
    if (fn(__VERIFIER_nondet_int()) == 999) i--;
    else i++;
    return i;
}