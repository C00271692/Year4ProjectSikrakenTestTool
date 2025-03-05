int main() {
    int i = 0x10;
    double d_testcomp = 0x1.FFFFFEp+127; //from double_req_bl_0682b.c
    double d_more = 0x1.19999ap0;
    // Floating-point constants
    float f1 = 123.0f;           // float
    float f2 = 123.0F;           // float
    double d1 = 123.0;           // double (default type for floating-point literals)
    double d2 = 123.;           // double (default type for floating-point literals)
    double d3 = 123.E10;           // double (default type for floating-point literals)
    long double ld1 = 123.E10L;           // double (default type for floating-point literals)
    long double ld2 = 123.0L;    // long double
    long double ld3 = 123.0l;    // long double

    // Floating-point constants with exponent notation and no digits after the decimal point
    float f3 = 1e2f;            // float, exponent notation with no decimal digits
    float f4 = 1E2F;            // float, exponent notation with no decimal digits
    double d4 = 1e2;            // double, exponent notation with no decimal digits
    double d5 = 1E2;            // double, exponent notation with no decimal digits
    long double ld4 = 1e2L;     // long double, exponent notation with no decimal digits
    long double ld5 = 1E2l;     // long double, exponent notation with no decimal digits

    // Floating-point constants with hexadecimal notation and no digits after the decimal point
    float f5 = 0x1p2f;         // 4.0 float, hexadecimal notation with no decimal digits
    double d6 = 0x1p2;         // double, hexadecimal notation with no decimal digits
    long double ld6 = 0x1p2L;  // long double, hexadecimal notation with no decimal digits

    // Floating-point constants with optional decimal point
    float f6 = 1.E1f;          // float, exponent notation with optional decimal point
    double d7 = 1.E1;          // double, exponent notation with optional decimal point
    long double ld7 = 1.E1L;   // long double, exponent notation with optional decimal point

     // Hexadecimal floating-point constants with no decimal part and various exponents
    float f7 = 0x1.0p0f;     // float, hexadecimal notation with no decimal digits and exponent 0
    float f8 = 0x1.0p1f;     // float, hexadecimal notation with no decimal digits and exponent 1
    float f9 = 0x1.0p2f;     // float, hexadecimal notation with no decimal digits and exponent 2
    float f10 = 0x1.0p3f;     // float, hexadecimal notation with no decimal digits and exponent 3
    float f11 = 0x1.p3f;     // float, hexadecimal notation with no decimal digits and exponent 3

    // Hexadecimal floating-point constants with some digits after the decimal point
    float f12 = 0x1.4p1f;     // float, hexadecimal notation with some decimal digits and exponent 1
    float f13 = 0x1.8p1f;     // float, hexadecimal notation with some decimal digits and exponent 1
    float f14 = 0x1.Cp2f;     // float, hexadecimal notation with some decimal digits and exponent 2
    float f15 = 0x1.fp2f;     // float, hexadecimal notation with some decimal digits and exponent 2

    // Double precision hexadecimal floating-point constants
    double d8 = 0x1.0p0;     // double, hexadecimal notation with no decimal digits and exponent 0
    double d9 = 0x1.0p1;     // double, hexadecimal notation with no decimal digits and exponent 1
    double d10 = 0x1.0p2;     // double, hexadecimal notation with no decimal digits and exponent 2
    double d11 = 0x1.0p3;     // double, hexadecimal notation with no decimal digits and exponent 3

    double d12 = 0x1.4p1;     // double, hexadecimal notation with some decimal digits and exponent 1
    double d13 = 0x1.8p1;     // double, hexadecimal notation with some decimal digits and exponent 1
    double d14 = 0x1.Cp2;     // double, hexadecimal notation with some decimal digits and exponent 2
    double d15 = 0x1.fp2;     // double, hexadecimal notation with some decimal digits and exponent 2

    // Long double precision hexadecimal floating-point constants
    long double ld8 = 0x1.0p0L; // long double, hexadecimal notation with no decimal digits and exponent 0
    long double ld9 = 0x1.0p1L; // long double, hexadecimal notation with no decimal digits and exponent 1
    long double ld10 = 0x1.0p2L; // long double, hexadecimal notation with no decimal digits and exponent 2
    long double ld11 = 0x1.0p3L; // long double, hexadecimal notation with no decimal digits and exponent 3

    long double ld12 = 0x1.4p1L; // long double, hexadecimal notation with some decimal digits and exponent 1
    long double ld13 = 0x1.8p1L; // long double, hexadecimal notation with some decimal digits and exponent 1
    long double ld14 = 0x1.Cp2L; // long double, hexadecimal notation with some decimal digits and exponent 2
    long double ld15 = 0x1.fp2L; // long double, hexadecimal notation with some decimal digits and exponent 2

}