#include <assert.h>
#include "char_overflow.c"

void test_1(void) {


	assert(char_overflow() == -128);
}
