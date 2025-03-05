extern int __VERIFIER_nondet_int(void);

int main() {
    int i, luck = 0;
    do {
        i = __VERIFIER_nondet_int();
        switch (i) {
            case 13 : case 7 :
                luck++;
                luck++;
                break;
            case 666 : case -42 :
                luck--;
                break;
            case 999: 
                luck-=999;
                break;
            case -1000000:
                return i;
            case 42:
                luck +=i;
            default: 
                ;
        }
    } while (i != 1111111);
    return luck;
}