/*
 * Date: 2012-02-12
 * Author: leike@informatik.uni-freiburg.de
 *
 * This version of the task exhibits an integer overflow. //I don't know why this is true
 */

extern int __VERIFIER_nondet_int(void);

int main()
{
	int y = __VERIFIER_nondet_int();
	while (y > 1) {
		if (y % 2 == 0) {	// y is even
			y = y / 2;		// and stays even: will eventually reach 2 and then 0 (and out of the loop)
		} else {
			y = 3*y + 1;	// y is odd and becomes even, will eventually reach 0 (and out of the loop)
		}
	}
	return 0;
}
