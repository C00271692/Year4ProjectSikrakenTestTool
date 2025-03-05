#include <assert.h>
#include "pre_increment.c"

void test_1(void) {

	int x = -1;

	assert(pre_increment(x) == 1);
}

void test_2(void) {

	int x = -1;

	assert(pre_increment(x) == 1);
}
