#include <assert.h>
#include "use_global_three_times.c"

void test_1(void) {

	x = 0;
	int x = 0;

	assert(use_global_three_times(x) == 9);
}
