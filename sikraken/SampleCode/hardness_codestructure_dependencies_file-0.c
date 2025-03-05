// This file is part of the SV-Benchmarks collection of verification tasks:
// https://gitlab.com/sosy-lab/benchmarking/sv-benchmarks
//
// SPDX-FileCopyrightText: 2022 Jana (Philipp) Berger
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Prototype declarations of the functions used to communicate with the model checkers
extern unsigned long __VERIFIER_nondet_ulong();
extern long __VERIFIER_nondet_long();
extern unsigned char __VERIFIER_nondet_uchar();
extern char __VERIFIER_nondet_char();
extern unsigned short __VERIFIER_nondet_ushort();
extern short __VERIFIER_nondet_short();
extern float __VERIFIER_nondet_float();
extern double __VERIFIER_nondet_double();

extern void abort(void);
extern void __assert_fail(const char *, const char *, unsigned int, const char *) __attribute__ ((__nothrow__ , __leaf__)) __attribute__ ((__noreturn__));
void reach_error() { __assert_fail("0", "Req1_Prop1_Batch0dependencies.c", 13, "reach_error"); }
void __VERIFIER_assert(int cond) { if(!(cond)) { ERROR: {reach_error();abort();} } return; }
void assume_abort_if_not(int cond) { if(!cond) { abort(); } }



#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))
#define abs(a) (((a) < 0 ) ? -(a) : (a))





// Function prototypes


// Internal control logic variables
unsigned char isInitial = 0;

// Signal variables
signed long int var_1_1 = 0;
signed long int var_1_5 = 2;
signed short int var_1_6 = -10;
unsigned long int var_1_7 = 1;
unsigned char var_1_8 = 0;
unsigned long int var_1_9 = 3470417420;
unsigned char var_1_10 = 0;
double var_1_12 = 25.6;
double var_1_13 = 1.75;
float var_1_14 = 5.4;
float var_1_15 = 127.5;
float var_1_16 = 3.5;
signed long int var_1_17 = 64;

// Calibration values

// Last'ed variables
signed long int last_1_var_1_1 = 0;
signed long int last_1_var_1_5 = 2;
signed short int last_1_var_1_6 = -10;
unsigned long int last_1_var_1_7 = 1;
float last_1_var_1_14 = 5.4;
signed long int last_1_var_1_17 = 64;

// Additional functions


void initially(void) {
}



void step(void) {
	// From: Req7Batch0dependencies
	if (((last_1_var_1_14 + last_1_var_1_14) / 9.2) < (min (last_1_var_1_14 , var_1_16))) {
		var_1_17 = (max (last_1_var_1_1 , last_1_var_1_6));
	} else {
		var_1_17 = last_1_var_1_6;
	}


	// From: Req1Batch0dependencies
	if (last_1_var_1_7 > (- last_1_var_1_5)) {
		var_1_1 = (max (last_1_var_1_5 , (last_1_var_1_7 + last_1_var_1_6)));
	} else {
		var_1_1 = (min ((1 - last_1_var_1_7) , 16));
	}


	// From: Req3Batch0dependencies
	if (last_1_var_1_17 < (- last_1_var_1_1)) {
		var_1_6 = (32 - last_1_var_1_6);
	}


	// From: Req4Batch0dependencies
	if (var_1_17 > var_1_17) {
		if (var_1_6 <= var_1_1) {
			var_1_7 = (abs (var_1_17));
		}
	}


	// From: Req6Batch0dependencies
	if ((var_1_12 * last_1_var_1_14) > var_1_13) {
		if (var_1_9 < var_1_7) {
			var_1_14 = var_1_15;
		} else {
			var_1_14 = var_1_15;
		}
	} else {
		var_1_14 = var_1_16;
	}


	// From: Req2Batch0dependencies
	if (var_1_6 < var_1_17) {
		var_1_5 = ((var_1_17 - var_1_6) + var_1_6);
	}


	// From: Req5Batch0dependencies
	if ((- 8u) >= (var_1_9 - var_1_6)) {
		var_1_8 = (! var_1_10);
	} else {
		var_1_8 = (((var_1_14 / var_1_12) >= var_1_14) || var_1_10);
	}
}



void updateVariables() {
	var_1_9 = __VERIFIER_nondet_ulong();
	assume_abort_if_not(var_1_9 >= 2147483647);
	assume_abort_if_not(var_1_9 <= 4294967295);
	var_1_10 = __VERIFIER_nondet_uchar();
	assume_abort_if_not(var_1_10 >= 1);
	assume_abort_if_not(var_1_10 <= 1);
	var_1_12 = __VERIFIER_nondet_double();
	assume_abort_if_not((var_1_12 >= -922337.2036854776000e+13F && var_1_12 <= -1.0e-20F) || (var_1_12 <= 9223372.036854776000e+12F && var_1_12 >= 1.0e-20F ));
	assume_abort_if_not(var_1_12 != 0.0F);
	var_1_13 = __VERIFIER_nondet_double();
	assume_abort_if_not((var_1_13 >= -922337.2036854776000e+13F && var_1_13 <= -1.0e-20F) || (var_1_13 <= 9223372.036854776000e+12F && var_1_13 >= 1.0e-20F ));
	var_1_15 = __VERIFIER_nondet_float();
	assume_abort_if_not((var_1_15 >= -922337.2036854765600e+13F && var_1_15 <= -1.0e-20F) || (var_1_15 <= 9223372.036854765600e+12F && var_1_15 >= 1.0e-20F ));
	var_1_16 = __VERIFIER_nondet_float();
	assume_abort_if_not((var_1_16 >= -922337.2036854765600e+13F && var_1_16 <= -1.0e-20F) || (var_1_16 <= 9223372.036854765600e+12F && var_1_16 >= 1.0e-20F ));
}



void updateLastVariables() {
	last_1_var_1_1 = var_1_1;
	last_1_var_1_5 = var_1_5;
	last_1_var_1_6 = var_1_6;
	last_1_var_1_7 = var_1_7;
	last_1_var_1_14 = var_1_14;
	last_1_var_1_17 = var_1_17;
}

int property() {
	return (((((((last_1_var_1_7 > (- last_1_var_1_5)) ? (var_1_1 == ((signed long int) (max (last_1_var_1_5 , (last_1_var_1_7 + last_1_var_1_6))))) : (var_1_1 == ((signed long int) (min ((1 - last_1_var_1_7) , 16))))) && ((var_1_6 < var_1_17) ? (var_1_5 == ((signed long int) ((var_1_17 - var_1_6) + var_1_6))) : 1)) && ((last_1_var_1_17 < (- last_1_var_1_1)) ? (var_1_6 == ((signed short int) (32 - last_1_var_1_6))) : 1)) && ((var_1_17 > var_1_17) ? ((var_1_6 <= var_1_1) ? (var_1_7 == ((unsigned long int) (abs (var_1_17)))) : 1) : 1)) && (((- 8u) >= (var_1_9 - var_1_6)) ? (var_1_8 == ((unsigned char) (! var_1_10))) : (var_1_8 == ((unsigned char) (((var_1_14 / var_1_12) >= var_1_14) || var_1_10))))) && (((var_1_12 * last_1_var_1_14) > var_1_13) ? ((var_1_9 < var_1_7) ? (var_1_14 == ((float) var_1_15)) : (var_1_14 == ((float) var_1_15))) : (var_1_14 == ((float) var_1_16)))) && ((((last_1_var_1_14 + last_1_var_1_14) / 9.2) < (min (last_1_var_1_14 , var_1_16))) ? (var_1_17 == ((signed long int) (max (last_1_var_1_1 , last_1_var_1_6)))) : (var_1_17 == ((signed long int) last_1_var_1_6)))
;
}
int main(void) {
	isInitial = 1;
	initially();

	while (1) {
		updateLastVariables();

		updateVariables();
		step();
		__VERIFIER_assert(property());
		isInitial = 0;
	}

	return 0;
}
