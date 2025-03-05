#include <stdlib.h>
#include <stdio.h>
#include "destructive_assignment_tests.c"

int main()
{
	test_1();
	test_2();
	test_3();

	printf("Tests for destructive_assignment ran successfully");
	return EXIT_SUCCESS;
}
