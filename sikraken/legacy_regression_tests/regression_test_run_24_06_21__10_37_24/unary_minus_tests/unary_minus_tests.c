#include <assert.h>
#include "unary_minus.c"

void test_1(void) {

	int x = 1;

	assert(unary_minus(x) == -1);
}

void test_2(void) {

	int x = 0;

	assert(unary_minus(x) == 0);
}
