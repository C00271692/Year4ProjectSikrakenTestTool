#include <assert.h>
#include "is_even.c"

void test_1(void) {

	int x = 0;

	assert(is_even(x) == 1);
}

void test_2(void) {

	int x = 1;

	assert(is_even(x) == 0);
}
