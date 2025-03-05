extern int __VERIFIER_nondet_int();
int main() {
    int x;
    char ab;
    char m = 'm';   //usual 'm' char, not an escape
    // Standard escape sequences
    char null_char = '\0';              // 0'\x0\   0   Null character    
    char bell = '\a';                   // 0'\a     7   Bell (alert)
    char backspace = '\b';              // 0'\b     8   Backspace
    char question_mark = '\?';          // '?' or 0'\x3F\   63  Question Mark
    char tab = '\t';                    // 0'\t     9   Horizontal tab
    char newline = '\n';                // 0'\n     10  Newline
    char vertical_tab = '\v';           // 0'\v     11  Vertical tab
    char form_feed = '\f';              // 0'\f     12  Form Feed
    char carriage_return = '\r';        // 0'\r     13  Carriage return
    char single_quote = '\'';           // 0'\'     39  Single quote
    char double_quote = '\"';           // 0'\"     34  Double quote
    char backslash = '\\';              // 0'\\     92  Backslash

    // Octal escape sequences
    char octal_A = '\101';             // Octal for 'A' (65 in decimal)
    char octal_B = '\102';             // Octal for 'B' (66 in decimal)
    char octal_space = '\040';         // Octal for space (32 in decimal)
    
    // Hexadecimal escape sequences
    char hex_Nul = '\x0';               // 0
    char hex_A = '\x41';                // 0'\x41\ Hexadecimal for 'A' (65 in decimal)
    char hex_B = '\x42';                // 0'\x42\ Hexadecimal for 'B' (66 in decimal)
    char hex_space = '\x20';            // 0'\x20\ Hexadecimal for space (32 in decimal)

    int i = __VERIFIER_nondet_int();
    return 0;
}