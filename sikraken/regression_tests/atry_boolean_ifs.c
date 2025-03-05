extern void exit(int);
extern int __VERIFIER_nondet_int(); 
int main() {
    int y = 0;
    int x = __VERIFIER_nondet_int();
    if (x == 0 || x == 1 || x == 2 || x == 3) y++;
    else y--;
    if (x == 3) y++;
    else {
        if (!(x>1)) y++;
        else y--;
    }
}