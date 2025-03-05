#include <assert.h>
#include "excess_comma.c"

void test_1(void) {

	int x = 0;

	assert(excess_comma(x) == 0);
}
