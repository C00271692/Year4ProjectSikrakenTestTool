#include <assert.h>
#include "is_five.c"

void test_1(void) {

	int x = 5;

	assert(is_five(x) == 1);
}

void test_2(void) {

	int x = 0;

	assert(is_five(x) == 0);
}
