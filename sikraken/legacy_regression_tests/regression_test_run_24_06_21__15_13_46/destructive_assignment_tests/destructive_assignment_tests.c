#include <assert.h>
#include "destructive_assignment.c"

void test_1(void) {

	int x = 5000000;
	int y = 0;

	assert(destructive_assignment(x,y) == 1);
}

void test_2(void) {

	int x = 0;
	int y = 0;

	assert(destructive_assignment(x,y) == 1);
}

void test_3(void) {

	int x = -5000000;
	int y = 0;

	assert(destructive_assignment(x,y) == 42);
}
