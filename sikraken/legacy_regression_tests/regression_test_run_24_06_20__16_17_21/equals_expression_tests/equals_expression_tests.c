#include <assert.h>
#include "equals_expression.c"

void test_1(void) {

	int x = 0;

	assert(equals_expression(x) == 3);
}
