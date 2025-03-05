#include <assert.h>
#include "check_local_scope.c"

void test_1(void) {


	assert(check_local_scope() == 5);
}
