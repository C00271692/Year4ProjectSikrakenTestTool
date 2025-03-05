#include <assert.h>
#include "bad_return_lt.c"

void test_1(void) {

	int x = 0;

	assert(bad_return_lt(x) == 2);
}
