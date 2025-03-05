extern int __VERIFIER_nondet_int();
extern char __VERIFIER_nondet_char();
//#include <stdio.h>
int main() {
    int sol = 0;   
    int nota = __VERIFIER_nondet_int();
    if (~nota == 42) ;              // Bitwise not (~)
    else ;

    char char_not = __VERIFIER_nondet_char();
    if (~char_not == -61) ;         // Bitwise not (~)
    else ;

    int shift_left = __VERIFIER_nondet_int();
    if (shift_left << 1 == 10) ;    // Bitwise left shift (<<)
    else ;
    
    int shift_right = __VERIFIER_nondet_int();
    if (shift_right >> 1 == 2);     // Bitwise right shift (>>)
    else ;
/*
    // Bitwise AND (&)
    int a = 12;    // 1100 in binary
    int b = 10;    // 1010 in binary
    int and_result = a & b;  // 1000 in binary -> 8
    if (and_result == 8) sol++;

    // Bitwise OR (|)
    int or_result = a | b;   // 1110 in binary -> 14
    if (or_result == 14) sol++;

    // Bitwise XOR (^)
    int xor_result = a ^ b;  // 0110 in binary -> 6
    if (xor_result == 6) sol++;

    // Bitwise NOT (~)
    unsigned int c = 0x0F;   // 00001111 in binary
    unsigned int not_result = ~c;  // 11110000 in binary (with unsigned) -> 0xFFFFFFF0
    if (not_result == 0xFFFFFFF0) sol++;

    // Using bitwise operators with `char` type
    char e = 0x3C;           // 00111100 in binary, 61 in decimal
    char f = 0x0F;           // 00001111 in binary
    char char_and = e & f;    // 00001100 in binary -> 12
    if (char_and == 12) sol++;

    char char_or = e | f;     // 00111111 in binary -> 63
    if (char_or == 63) sol++;

    char char_xor = e ^ f;    // 00110011 in binary -> 51
    if (char_xor == 51) sol++;
*/
    return 0;
}