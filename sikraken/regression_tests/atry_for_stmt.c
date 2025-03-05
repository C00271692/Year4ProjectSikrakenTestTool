extern void exit(int);
extern int __VERIFIER_nondet_int();
int main() {
    int v = __VERIFIER_nondet_int();
    int tot = 0;
    for (int i = 0; i < 10; i++) {  //classic
        tot = tot + i;
    }
    for (int i = 0; i < 10; ) { //no update
        tot = tot + i;
        i++;
    }
    for (int i = 0; ; ) { //no condition, no update
        tot = tot + i;
        i++;
        if (i>=10) break;
    }
    int i = 0;
    for ( ; ; ) { //no initialisation, no condition, no update
        tot = tot + i;
        i++;
        if (i>=10) break;
    }
    if (v==tot) ;
    else ;
}