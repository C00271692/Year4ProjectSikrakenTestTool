extern int __VERIFIER_nondet_int();
int unknown_length[];    //array of unknown_length, GCC gives it 1 element... [how to deal with this?]
int b[5];   //initialised with 0s
int main() {
    int r = 0;
    int unknown_length_init[] = {__VERIFIER_nondet_int(), 6, 7};   //size 3, fully initialised
    if (unknown_length_init[0] == 43) r++;
    else r--;
    int c[10] = {5, 6}; //only first 2 elements are initialised, the rest are set to default
    int zzz = c[0] + c[1];
    zzz += c[2];
    int i = __VERIFIER_nondet_int();
    b[i] = 0;   
    b[0] = 12;

    int x = b[0] + b[1];    //evaluate to 12 + ?
    int a[] = {44,45,46,47,48,49};
	int *ap = a;    //a is a pointer to an array
    x += ap[3] + a[3];   //106
    int input = __VERIFIER_nondet_int();
    if (input == x) r++; else r--;
    return 0;
}