#include <assert.h>
#include "static_variable_value_assigned.c"

void test_1(void) {


	assert(static_variable_value_assigned() == 23);
}
