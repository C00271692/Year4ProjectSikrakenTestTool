int main() {
    //large decimal integer constants without suffixes
    const int large_int = 2147483647;                // Max value for a 32-bit int
    const long large_long = 9223372036854775807;     // Max value for a 64-bit long (on most platforms)
    const unsigned long long large_ull = 18446744073709551615; // Max value for unsigned long long
    
    // Define large integer constants in hexadecimal
    const int large_int_hex = 0x7FFFFFFF;              // Max value for a 32-bit int
    const unsigned int large_unsigned_int = 0xFFFFFFFF; 
    const long large_long_hex = 0x7FFFFFFFFFFFFFFF;   // Max value for a 64-bit long (on most platforms)
    const unsigned long long large_ull_hex = 0xFFFFFFFFFFFFFFFF; // Max value for unsigned long long

    // Define large integer constants in octal
    const int large_int_octal = 017777777777;            // Octal representation of 2147483647
    const long large_long_octal = 01777777777777777777777; // Octal representation of 9223372036854775807
    const unsigned long long large_ull_octal = 01777777777777777777777777777777; // Octal representation of 18446744073709551615

    // Decimal constants
    int dec1 = 123;
    unsigned int dec2 = 123u;         // unsigned
    unsigned int dec3 = 123U;         // unsigned
    long dec4 = 123l;                 // long
    long dec5 = 123L;                 // long
    unsigned long dec6 = 123ul;       // unsigned long
    unsigned long dec7 = 123UL;       // unsigned long
    long long dec8 = 123ll;           // long long
    long long dec9 = 123LL;           // long long
    unsigned long long dec10 = 123ull; // unsigned long long
    unsigned long long dec11 = 123ULL; // unsigned long long

    // Hexadecimal constants
    int hex1 = 0x7B;                  // standard hexadecimal
    unsigned int hex2 = 0x7Bu;        // unsigned
    unsigned int hex3 = 0x7BU;        // unsigned
    long hex4 = 0x7Bl;                // long
    long hex5 = 0x7BL;                // long
    unsigned long hex6 = 0x7Bul;      // unsigned long
    unsigned long hex7 = 0x7BUL;      // unsigned long
    long long hex8 = 0x7Bll;          // long long
    long long hex9 = 0x7BLL;          // long long
    unsigned long long hex10 = 0x7Bull; // unsigned long long
    unsigned long long hex11 = 0x7BULL; // unsigned long long

    // Octal constants
    int oct1 = 0173;                  // standard octal
    unsigned int oct2 = 0173u;        // unsigned
    unsigned int oct3 = 0173U;        // unsigned
    long oct4 = 0173l;                // long
    long oct5 = 0173L;                // long
    unsigned long oct6 = 0173ul;      // unsigned long
    unsigned long oct7 = 0173UL;      // unsigned long
    long long oct8 = 0173ll;          // long long
    long long oct9 = 0173LL;          // long long
    unsigned long long oct10 = 0173ull; // unsigned long long
    unsigned long long oct11 = 0173ULL; // unsigned long long
}