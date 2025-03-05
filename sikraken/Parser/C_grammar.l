/****************************************************************************************************/
/* C11 lexer file from https://www.quut.com/c/ANSI-C-grammar-l-2011.html                            */
/* Flex documentation: https://westes.github.io/flex/manual/index.html                        */
/****************************************************************************************************/
/* definition section */
%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117

%option yylineno

%{
#ifdef _MSC_VER
    #define strdup_safe(char_ptr) _strdup(char_ptr)
#else
    #define strdup_safe(char_ptr) strdup(char_ptr)
#endif

#include <stdio.h>
#include <limits.h>

#include "C_grammar.tab.h"

void read_comment();
int convert_escape_sequence(const char *);
int differentiate_identifiers(char *);
void wrap_integer_constants(char *, char *, char **);
void wrap_floating_point_constants(int, char *, char **);
void add_missing_zero(char *, char **);

int open_parens = 0;        //Declaration in the definitions section

%}

%x ATTRIBUTE

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z$_]
A   [a-zA-Z$_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%%
        /* rules section */
"/*"                                        { read_comment(); }
"//".*                                      { /* consume //-comment */ }
"#pragma".*                                 { /* Ignore the entire line after `#pragma` */ }
"__extension__"                             { /* Ignoring GCC keyword __extension__ that disables compiler warnings about non-compliant features */ }
"__attribute__"[ ]*\([ ]*\(                 { /* Ignoring all GCC __attribute__ at our peril obviously */ 
                                             open_parens = 2;   //Start with the initial two opening parentheses
                                             BEGIN(ATTRIBUTE);  //Enter the ATTRIBUTE start condition to read everything until the final 2 closing parenthesis
                                            }
<ATTRIBUTE>. {                  //use this because flex regular expressions cannot match matching inner parentheses as in __attribute__ ((__nonnull__ (1, 2))) or __asm__("addl $3, %0" : "=r" (result) : "0" (result) : "cc")
    if (yytext[0] == '(') { 
        open_parens++;          //Increment for each additional opening parenthesis
    } 
    else if (yytext[0] == ')') { 
        open_parens--;          //Decrement for each closing parenthesis
        if (open_parens == 0) {
            BEGIN(INITIAL);     //Exit ATTRIBUTE mode after the matched parentheses are balanced
        }
    }
    /* Otherwise, continue reading characters in ATTRIBUTE mode */
}
<ATTRIBUTE><<EOF>> { /* Handle unexpected EOF */
    fprintf(stderr, "Error: Unclosed __attribute__(( found.\n");
    exit(1);
}
"__asm__"[ ]*\(                             { /* Ignoring all GCC __asm__ at our peril obviously */ 
                                             open_parens = 1;   //Start with the initial single opening parenthesis
                                             BEGIN(ATTRIBUTE);  //Enter the ATTRIBUTE start condition to read everything until the final closing parenthesis
                                            }
"auto"					{ return(AUTO); }
"break"					{ return(BREAK); }
"case"					{ return(CASE); }
"char"					{ return(CHAR); }
"const"					{ return(CONST); }
"continue"				{ return(CONTINUE); }
"default"				{ return(DEFAULT); }
"do"					{ return(DO); }
"double"				{ return(DOUBLE); }
"else"					{ return(ELSE); }
"enum"					{ return(ENUM); }
"extern"				{ return(EXTERN); }
"float"					{ return(FLOAT); }
"for"					{ return(FOR); }
"goto"					{ in_label_namespace = 1; return(GOTO); } //special namespace for labels GOTO
"if"					{ return(IF); }
"inline"				{ return(INLINE); }
"__inline"				{ return(INLINE); }     //GCC version of INLINE
"int"					{ return(INT); }
"long"					{ return(LONG); }
"register"				{ return(REGISTER); }
"restrict"				{ return(RESTRICT); }
"__restrict"            { return(RESTRICT); }   //GCC version of RESTRICT
"return"				{ return(RETURN); }
"short"					{ return(SHORT); }
"signed"				{ return(SIGNED); }
"sizeof"				{ return(SIZEOF); }
"static"				{ return(STATIC); }
"struct"				{ return(STRUCT); }
"switch"				{ return(SWITCH); }
"typedef"				{ return(TYPEDEF); }
"union"					{ return(UNION); }
"unsigned"				{ return(UNSIGNED); }
"void"					{ return(VOID); }
"volatile"				{ return(VOLATILE); }
"while"					{ return(WHILE); }
"__int128"              { return(INT128); }     //GCC builtin 128-bit integer type
"_Float32"              { return(FLOAT); }      //GCC builtin 32-bit floating-point type
"_Float64"              { return(DOUBLE); }     //GCC builtin 64-bit floating-point type
"__float128"            { return(FLOAT128); }   //GCC builtin 128-bit floating-point type
"_Float128"             { return(FLOAT128); }   //GCC builtin 128-bit floating-point type
"__builtin_va_list"     { return(VA_LIST); }    //GCC builtin variable argument list type
"_Alignas"              { return ALIGNAS; }
"_Alignof"              { return ALIGNOF; }
"_Atomic"{WS}*"("       { return ATOMIC_SPECIFIER; }
"_Atomic"               { return ATOMIC; }
"_Bool"                 { return BOOL; }
"_Complex"              { return COMPLEX; }
"_Generic"              { return GENERIC; }
"_Imaginary"            { return IMAGINARY; }
"_Noreturn"             { return NORETURN; }
"_Static_assert"        { return STATIC_ASSERT; }
"_Thread_local"         { return THREAD_LOCAL; }
"__PRETTY_FUNCTION__"   { return FUNC_NAME; }   //__PRETTY_FUNCTION__ is a GCC extension: an enhanced version of __func__; which we ignore 
"__func__"              { return FUNC_NAME; }

{L}{A}*                     {size_t const size = strlen(yytext) + 1;
                             yylval.id = (char*)malloc(size);
                             int i = 0;
                             for (; yytext[i] != '\0'; i++) {
                                if (yytext[i] == '$') {
                                    yylval.id[i] = 'Z';         //replace all '$' in C identifers (allowed extension) with the character 'Z' becuase $ is not allowed in C var names: this is unsound when another identifier already has this name e.g. $1 and Z1 will clash
                                } else {
                                    yylval.id[i] = yytext[i];
                                }
                             }
                             yylval.id[i] = '\0';
                             if (in_member_namespace || in_tag_declaration || in_label_namespace) 
                                return IDENTIFIER;
                             if (in_ordinary_id_declaration) {  //declaring a new IDENTIFIER
                                if (is_typedef_name(yylval.id)) {
                                    //shadowing of typedef occuring: push the identifier onto the typedef stack with the current scope level
                                    add_typedef_id(current_scope, yylval.id, 0);   //0 indicates that it is an ordinary id
                                    if (debugMode) printf("Debug: SHADOWING of a typedef_name found: %s on line %d\n", yylval.id, yylineno);
                                }
                                return IDENTIFIER;
                             }
                             if (is_typedef_name(yylval.id)) {
                                if (debugMode) printf("Debug: returning TYPEDEF_NAME %s from lexer on line %d\n", yylval.id, yylineno);
                                return TYPEDEF_NAME;
                             } else {
                                return IDENTIFIER; //not an ordinary declaration but ordinary id
                             }
                            }

{HP}{H}+{IS}?				{wrap_integer_constants("16'", &yytext[2], &yylval.id);     //hexadecimal integer
                             return I_CONSTANT;
                            }
{NZ}{D}*{IS}?				{wrap_integer_constants("", yytext, &yylval.id);            //decimal integer
                             return I_CONSTANT;
                            }
                            
"0"{O}*{IS}?				{if (isdigit(yytext[1])) wrap_integer_constants("8'", &yytext[1], &yylval.id);  //octal integer 
                             else {     //the second char after 0 is not a digit (it's /0, ofr an IS (u|U)(l|L|ll|LL) char), so it's just the constant 0, rather than a true octal 
                                yylval.id = (char*)malloc(7);
                                strcpy(yylval.id, "int(0)");    
                             }
                             return I_CONSTANT;
                            }
{CP}?"'"([^'\\\n]|{ES})+"'"	{//single char 
                             char *content = yytext + (yytext[0] == '\'' ? 1 : 2);  //Skip prefix and opening quote
                             content[strlen(content) - 1] = '\0';                   //Remove closing quote
                             int ascii;
                             if (content[0] == '\\') {                              //it's an escape sequence
                                    ascii = convert_escape_sequence(content);
                             } else {
                                    ascii = (int)content[0];
                             }
                             yylval.id = (char*)malloc(10);
                             sprintf(yylval.id, "int(%d)", ascii);
                             return I_CONSTANT;
                            }       

{D}+{E}{FS}?				{wrap_floating_point_constants(0, yytext, &yylval.id);     //Decimal floating-point constants with an exponent.
                             return F_CONSTANT;
                            }
{D}*"."{D}+{E}?{FS}?		{wrap_floating_point_constants(0, yytext, &yylval.id);     //Decimal floating-point constants with a fractional part.
                             return F_CONSTANT;
                            }
{D}+"."{E}?{FS}?			{char* added_0;
                             add_missing_zero(yytext, &added_0);
                             wrap_floating_point_constants(0, added_0, &yylval.id);            //Decimal floating-point constants with a fractional part.
                             return F_CONSTANT;
                            }
{HP}{H}+{P}{FS}?			{wrap_floating_point_constants(1, yytext, &yylval.id);  //Hexadecimal floating-point constants: will fail parser in ECLiPSe
                             return F_CONSTANT;
                            }
{HP}{H}*"."{H}+{P}{FS}?		{wrap_floating_point_constants(1, yytext, &yylval.id);  //Hexadecimal floating-point constants with a fractional part.: will fail parser in ECLiPSe
                             return F_CONSTANT;
                            }
{HP}{H}+"."{P}{FS}?			{char* added_0;
                             add_missing_zero(yytext, &added_0);
                             wrap_floating_point_constants(1, added_0, &yylval.id); //Hexadecimal floating-point constants with digits before the decimal point, but none after. : will fail parser in ECLiPSe
                             return F_CONSTANT;
                            }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{if (yytext[0] == 'L') { //a wide string constant
                                        size_t const size = strlen("wide_string()") + strlen(yytext) - 1 + 1;
                                        yylval.id = (char*)malloc(size);
                                        sprintf_safe(yylval.id, size, "wide_string(%s)", &yytext[1]);      //copy from yytext[1] to remove 'L' prefix 
                                     } else {
                                        yylval.id = strdup_safe(yytext);
                                     }
                                     return STRING_LITERAL;
                                    }

"..."					{ return ELLIPSIS; }
">>="					{ return RIGHT_ASSIGN; }
"<<="					{ return LEFT_ASSIGN; }
"+="					{ return ADD_ASSIGN; }
"-="					{ return SUB_ASSIGN; }
"*="					{ return MUL_ASSIGN; }
"/="					{ return DIV_ASSIGN; }
"%="					{ return MOD_ASSIGN; }
"&="					{ return AND_ASSIGN; }
"^="					{ return XOR_ASSIGN; }
"|="					{ return OR_ASSIGN; }
">>"					{ return RIGHT_OP; }
"<<"					{ return LEFT_OP; }
"++"					{ return INC_OP; }
"--"					{ return DEC_OP; }
"->"					{ return PTR_OP; }
"&&"					{ return AND_OP; }
"||"					{ return OR_OP; }
"<="					{ return LE_OP; }
">="					{ return GE_OP; }
"=="					{ return EQ_OP; }
"!="					{ return NE_OP; }
";"					    { return ';'; }
("{"|"<%")				{ return '{'; }
("}"|"%>")				{ return '}'; }
","					    { return ','; }
":"					    { return ':'; }
"="					    { return '='; }
"("					    { return '('; }
")"					    { return ')'; }
("["|"<:")				{ return '['; }
("]"|":>")				{ return ']'; }
"."					    { return '.'; }
"&"					    { return '&'; }
"!"					    { return '!'; }
"~"					    { return '~'; }
"-"					    { return '-'; }
"+"					    { return '+'; }
"*"					    { return '*'; }
"/"					    { return '/'; }
"%"					    { return '%'; }
"<"					    { return '<'; }
">"					    { return '>'; }
"^"					    { return '^'; }
"|"					    { return '|'; }
"?"					    { return '?'; }

{WS}+				    { /* whitespaces (including new lines) separate tokens */ }
.					    { /* discard bad characters */ }

%%
/* user code section */
int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

void read_comment() {
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;
            if (c == '/')
                return;
            if (c == 0)
                break;
        }
}

int convert_escape_sequence(const char *str) {
    if (strcmp(str, "\\0") == 0) return '\0';
    if (strcmp(str, "\\a") == 0) return '\a';
    if (strcmp(str, "\\b") == 0) return '\b';
    if (strcmp(str, "\\?") == 0) return '\?';
    if (strcmp(str, "\\f") == 0) return '\f';
    if (strcmp(str, "\\n") == 0) return '\n';
    if (strcmp(str, "\\r") == 0) return '\r';
    if (strcmp(str, "\\t") == 0) return '\t';
    if (strcmp(str, "\\v") == 0) return '\v';
    if (strcmp(str, "\\\\") == 0) return '\\';
    if (strcmp(str, "\\\'") == 0) return '\'';
    if (strcmp(str, "\\\"") == 0) return '"';
    if (str[1] >= '0' && str[1] <= '7') {   //Handle octal escape
        return (int)strtol(str + 1, NULL, 8);
    }
    if (str[1] == 'x') {                    //Handle hexadecimal escape
        return (int)strtol(str + 2, NULL, 16);
    }
    fprintf(stderr, "Invalid escape sequence: %s\n", str);
    exit(EXIT_FAILURE);
}

//add hexademical or octal wrapper and handle u|l|ll variations
void wrap_integer_constants(char *wrapper, char *input, char **output) {
    int current = strlen(input)-1;
    int has_u = 0, has_l = 0, has_ll = 0;
    int has_suffix = 1;

    while (has_suffix && current >= 0) {    //start from the end and move back until non u|U|l|L character is met
        switch (input[current]) {
            case 'u':
            case 'U':
                has_u = 1;
                break;
            case 'l':
            case 'L':
                if (current >0 && (input[current-1] == 'l' || input[current-1] == 'L')) {
                    has_ll = 1;
                    current--;  //skip the other 'l' or 'LL'
                }
                else has_l = 1;
                break;
            default:
                has_suffix = 0;  
        }
        if (has_suffix) current--;
    }
    int a = strcmp(wrapper, "");
    //calculating the length of the result: length of the wrapper + length of the prefix, the suffix, the underscore, the parenthesis
    int size = strlen(wrapper) + current+1 + 1 + has_u*strlen("unsigned") + has_l*strlen("long") + has_ll*strlen("long_long") + has_u*has_l + has_u*has_ll + (has_u || has_l || has_ll ? 2 : 0);

    char format_string[100];
    strcpy(format_string, "");

    if (!has_u && !has_l && !has_ll) {              //has no suffix, type depends on value
        unsigned long constant = strtoul(input, NULL, 0);         //the 0 enables automatic detection of base: decimal, octal or hexadecimal
        if (constant <= INT_MAX) {
            strcat(format_string, "int(");
            size += strlen("int()");
        } else if (a && constant <= UINT_MAX) {   //different rule for octals and hexademcimals
            strcat(format_string, "unsigned(");
            size += strlen("unsigned()");
        }
         else if (constant <= TARGET_LONG_MAX) {          //don't use LONG_MAX, values dependents on the target memory model size (32 vs 64 bits) of the program under test, not of the compiler used to generate the parser
            strcat(format_string, "long(");
            size += strlen("long()");
        } else {
            strcat(format_string, "unsigned_long(");   //todo check how long long constants without suffix are handled in gcc/ansi C currently set as unsigned long which is big enough
            size += strlen("unsigned_long()");
        }   
    }
    else if (has_u && !has_l && !has_ll) 
        strcat(format_string, "unsigned(");
    else if (has_u && has_l && !has_ll) 
        strcat(format_string, "unsigned_long(");
    else if (has_u && !has_l && has_ll) 
        strcat(format_string, "unsigned_long_long(");
    else if (!has_u && has_l && !has_ll) 
        strcat(format_string, "long(");
    else if (!has_u && !has_l && has_ll) 
        strcat(format_string, "long_long(");

    if (a) strcat(format_string, "%s");
    
    strcat(format_string, "%.*s)");

    *output = (char *)malloc(size);
    if (a) {
        snprintf(*output, size, format_string, wrapper, current + 1, input);
    } else {
        snprintf(*output, size, format_string, current + 1, input);
    }
}

//handle hexademical floating points and handle f|F|l|L variations
void wrap_floating_point_constants(int is_hexadecimal, char * input, char ** output) {
    int current = strlen(input)-1;
    int has_f = 0, has_l = 0, is_d = 0;
    int has_suffix = 1;

    switch (input[current]) {
        case 'f':
        case 'F':
            has_f = 1;
            break;
        case 'l':
        case 'L':
            has_l = 1;
            break;
        default:
            is_d = 1;
            has_suffix = 0;
    }
    if (has_suffix) current--;

    if (is_hexadecimal) {          //a floating point hexadecimal e.g. 0x1.FFFFFEp+127 becomes hex_float(double,"1.FFFFFE",+127)
        char *fraction = malloc((current + 1) * sizeof(char));
        char *power = malloc((current + 1) * sizeof(char));

        int j = 0, isPower = 0;
        for (int i = 0; i <= current; i++) {
            if (input[i] == 'p') {
                fraction[i - 2] = '\0'; 
                isPower = 1; 
                continue; 
            }
            if (isPower) {
                power[j++] = input[i];
            } else if (i >= 2) { 
                fraction[i - 2] = input[i];
            }
        }
        power[j] = '\0'; 
        char *type = "double";  // Default to "double"
        if (has_f) type = "float";
        else if (has_l) type = "long_double";

        int size = strlen("hex_float") + strlen(type) + strlen(fraction) + strlen(power) + 12; 
        *output = (char *)malloc(size);
        snprintf(*output, size, "hex_float(%s,\"%s\",%s)", type, fraction, power);
        free(fraction);
        free(power);
    }
    else {  //an ordinary decimal floating point literal
        //calculating the length of the result: length of the prefix, the suffix, the parenthesis
        int size = current+1 + 1 + is_d*strlen("double") + has_f*strlen("float") + has_l*strlen("long_double") + (has_f || has_l || is_d ? 2 : 0);
        *output = (char *)malloc(size);
        char format_string[100];
        strcpy(format_string, "");
        if (is_d) strcat(format_string, "double(%.*s)");      //double is the default type for floating points literals
        else if (has_f) strcat(format_string, "float(%.*s)");
        else if (has_l) strcat(format_string, "long_double(%.*s)");
        snprintf(*output, size, format_string, current + 1, input);
    }
}

//float has no digit after decimal point: need to add 0
void add_missing_zero(char * input, char ** output) {
    size_t len = strlen(input);
    *output = (char*)malloc(len + 1 + 1); // +1 for extra '0'
    strcpy(*output, input);
    char* decimal_point = strchr(*output, '.');
    char* suffix = strpbrk(decimal_point, "eElL"); //returns pointer to first occurrence of character
    if (suffix == NULL) {// No suffix, so it's the end of the string
        suffix = *output + strlen(*output);
    }
    size_t decimal_pos = decimal_point - *output;
    memmove(decimal_point + 2, decimal_point + 1, len - decimal_pos); //copy everything after the decimal point to +1 location
    (*output)[decimal_pos + 1] = '0';    //add the 'missing' 0
}