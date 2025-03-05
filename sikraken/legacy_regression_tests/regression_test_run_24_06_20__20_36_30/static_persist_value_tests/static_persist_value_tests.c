#include <assert.h>
#include "static_persist_value.c"

void test_1(void) {


	assert(static_persist_value() == 6);
}
