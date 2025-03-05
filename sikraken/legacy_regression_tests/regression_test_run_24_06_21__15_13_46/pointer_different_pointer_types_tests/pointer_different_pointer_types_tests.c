#include <assert.h>
#include "pointer_different_pointer_types.c"

void test_1(void) {


	assert(pointer_different_pointer_types() == 'a');
}
