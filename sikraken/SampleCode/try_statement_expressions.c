extern void abort(void);
#include <assert.h>
void reach_error() { assert(0); }
void __VERIFIER_assert(int cond) { if(!(cond)) { ERROR: {reach_error();abort();} } }
int __VERIFIER_nondet_int();


int main() {
  int x = __VERIFIER_nondet_int();
  x+1;    //expression statement in C...
  if (x > 0) {
    x++;
  } else {
    reach_error();
  }
}