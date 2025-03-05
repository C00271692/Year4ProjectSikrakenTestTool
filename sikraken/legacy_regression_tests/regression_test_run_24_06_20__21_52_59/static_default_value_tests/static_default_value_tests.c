#include <assert.h>
#include "static_default_value.c"

void test_1(void) {


	assert(static_default_value() == 0);
}
