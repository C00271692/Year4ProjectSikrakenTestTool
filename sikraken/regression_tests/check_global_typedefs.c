extern int __VERIFIER_nondet_int();
/*struct bus_info { //allowed in gcc
};
*/
typedef long unsigned int size_t;   //unsigned can appear anywhare and just at the start as by convention
//check typedef from aws_array_eq_c_str_harness.i
typedef struct {
    int x;
    int y;
} Point;
typedef long int __off64_t;
typedef unsigned long int __syscall_ulong_t;
const float pi = 3.14;
typedef __off64_t __loff_t;
typedef char *__caddr_t;
const float pi2 = 3.14;
//
typedef int Length;
Length len, maxlen;
typedef long Blockno, *Blockptr;    //K&R p. 221
typedef unsigned char SORT_1;
//typedef char *__caddr_t;            
typedef __caddr_t caddr_t;//sll-buckets-2.c 
const SORT_1 mask_SORT_1 = (SORT_1)-1 >> (sizeof(SORT_1) * 8 - 1);
typedef __builtin_va_list Length2;
typedef Length2 My_length;
typedef __builtin_va_list __gnuc_va_list;
typedef __gnuc_va_list va_list_8477;
struct _IO_FILE;        //forward declaration of struct _IO_FILE
typedef struct _IO_FILE FILE;       //3 aliases are declared
typedef struct _IO_FILE __FILE;

typedef struct _IO_FILE _IO_FILE;   

struct _IO_FILE{        //at last defines struct _IO_FILE
    int  Id_MCDC_0;
};

// Typedef for a function pointer that takes two ints and returns an int
typedef int (*operation_fn)(int, int);

// Example function that matches the typedef
int add(int a, int b) {
    return a + b;
}

int subtract(int a, int b) {
    return a - b;
}


//check if globals can be accessed
int x = 5;
int main() {
    int y = __VERIFIER_nondet_int();
    return x+y;
}