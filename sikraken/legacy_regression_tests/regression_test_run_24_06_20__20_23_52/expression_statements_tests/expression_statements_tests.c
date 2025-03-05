#include <assert.h>
#include "expression_statements.c"

void test_1(void) {

	int x = 0;

	assert(expression_statements(x) == 12345);
}
