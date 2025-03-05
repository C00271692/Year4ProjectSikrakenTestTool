#include <assert.h>
#include "return_expression.c"

void test_1(void) {

	int x = 0;

	assert(return_expression(x) == 0);
}
