#include <assert.h>
#include "pointer_change_underlying_value.c"

void test_1(void) {


	assert(pointer_change_underlying_value() == 10);
}
