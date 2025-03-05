#include <assert.h>
#include "bad_return_gt_equal.c"

void test_1(void) {

	int x = 0;

	assert(bad_return_gt_equal(x) == 1);
}
