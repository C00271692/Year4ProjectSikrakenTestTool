#include <assert.h>
#include "choose_local_over_global_scope.c"

void test_1(void) {

	x = 0;

	assert(choose_local_over_global_scope() == -99);
}
