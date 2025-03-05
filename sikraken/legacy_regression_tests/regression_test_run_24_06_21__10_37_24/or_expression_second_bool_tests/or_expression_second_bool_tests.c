#include <assert.h>
#include "or_expression_second_bool.c"

void test_1(void) {

	int x = 1;

	assert(or_expression_second_bool(x) == 1);
}

void test_2(void) {

	int x = -1;

	assert(or_expression_second_bool(x) == -1);
}

void test_3(void) {

	int x = 0;

	assert(or_expression_second_bool(x) == 0);
}
