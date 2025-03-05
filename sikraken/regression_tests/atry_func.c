int *funca();
int funcb(int b);

int a;
extern int __VERIFIER_nondet_int(void);

int *funca() {
    return &a;
}

int main() {
    int b;
    int *c;
    a = 56;
    c = funca();
    b = __VERIFIER_nondet_int();
    if (*c == b) ;
    else ;
    return 0;
}


