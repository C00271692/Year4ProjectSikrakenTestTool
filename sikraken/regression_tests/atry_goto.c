extern int __VERIFIER_nondet_int();

int main(void) {
 int x = 1;
 try_again: ;
 int y = __VERIFIER_nondet_int();
 if (y == -42) {
   goto weirderror; 
 }
weirderror: ;   
 if (y == 42) {
     ;      //Sikraken does not work if you insert weirderror: ;  here
 }
 int z = __VERIFIER_nondet_int();
 if (z == 666) {
   goto weirderror; //possibly infinite loop until we pick something else than 666
 }
 if (y == z) goto error;
 else goto try_again;
 return 0;
 error: return -1;
}