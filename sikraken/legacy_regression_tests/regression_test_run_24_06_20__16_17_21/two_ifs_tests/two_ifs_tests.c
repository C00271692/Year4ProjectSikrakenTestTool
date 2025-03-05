#include <assert.h>
#include "get_sign.c"

void test_1(void) {

	int x = 0;

	assert(two_ifs(x) == 0);
}

void test_2(void) {

	int x = 5000000;

	assert(two_ifs(x) == 1);
}

void test_3(void) {

	int x = -5000000;

	assert(two_ifs(x) == -1);
}
