#include <assert.h>
#include "post_increment.c"

void test_1(void) {

	int x = -1;

	assert(post_increment(x) == 0);
}

void test_2(void) {

	int x = -1;

	assert(post_increment(x) == 0);
}
