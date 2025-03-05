#include <assert.h>
#include "fib_helper.c"

void test_1(void) {

	int x = 9;

	assert(fib_helper(x) == 18);
}

void test_2(void) {

	int x = 0;

	assert(fib_helper(x) == 0);
}
