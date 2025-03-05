#include <assert.h>
#include "char_underflow.c"

void test_1(void) {


	assert(char_underflow() == 127);
}
