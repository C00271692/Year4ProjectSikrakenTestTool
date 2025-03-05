#include <assert.h>
#include "check_global.c"

void test_1(void) {

	y = 0;

	assert(check_global() == 5);
}
