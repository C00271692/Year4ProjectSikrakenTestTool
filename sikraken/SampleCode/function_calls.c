// function_calls.c
extern int __VERIFIER_nondet_int();

int calc(int x) {
  if (x>42) return 1;
  else return 0;
}

int two_params(int x, int y) {// 6 arcs and 6 goals in gcov
  if (x+y>42 || x == -5 && y == -2) 
    if (3 > 4) 
      if (5 < 78)
        return -1;
  else return 0;
}

int two_params_v2(int x, int y) {// 6 arcs and 6 goals in gcov
  if (x+y>42 || x == -5 && y == -2) 
    if (3 > 4) return -8;
      else if (7 > 8)
        return 2;
  else return 0;
}

int simplest_gcov_cfg_problem(int x) {
  if (x>8) return -1;     //this branch has no false arc in gcov
  else if (x <5) return -2;
      else return 42;
}

int gcov_test(int x) {
  int a;
  if (x > 2) for(int i; i<5; i++) a++;
  else return -1;
  return a;
}

int fibonacci(int n) {  //4 arcs but only 3 goals in gcov
    if (n == 0) {
        return 0; // Base case: Fibonacci(0) is 0
    } else
        if (n == 1) {
          return 1; // Base case: Fibonacci(1) is 1
        } else {
          return fibonacci(n - 1) + fibonacci(n - 2); // Recursive case
    }
}

int main() {
  int x, y, input, input2;
  input = __VERIFIER_nondet_int();
  y = fibonacci(5); // fibonacci(17) returns 1597 after 5167 calls
  x = x + calc(input) + calc(input) + two_params(input, input);
  input2 = __VERIFIER_nondet_int();
  if (input2 == 42) return input2;
}