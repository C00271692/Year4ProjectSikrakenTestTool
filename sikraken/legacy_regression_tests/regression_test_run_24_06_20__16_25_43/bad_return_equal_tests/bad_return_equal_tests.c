#include <assert.h>
#include "bad_return_equal.c"

void test_1(void) {

	int x = 0;

	assert(bad_return_equal(x) == 1);
}
