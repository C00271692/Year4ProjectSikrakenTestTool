#include <assert.h>
#include "and_expression.c"

void test_1(void) {

	int x = -2;

	assert(and_expression(x) == -2);
}

void test_2(void) {

	int x = 0;

	assert(and_expression(x) == 0);
}
