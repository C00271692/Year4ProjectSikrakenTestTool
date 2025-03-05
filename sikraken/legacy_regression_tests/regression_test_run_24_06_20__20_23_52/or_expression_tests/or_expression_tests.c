#include <assert.h>
#include "or_expression.c"

void test_1(void) {

	int x = 67;

	assert(or_expression(x) == 1);
}

void test_2(void) {

	int x = 0;

	assert(or_expression(x) == 0);
}
