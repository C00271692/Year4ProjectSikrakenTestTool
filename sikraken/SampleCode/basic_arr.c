#include <stdio.h>

int main() {
    char arr[5] = {1, 2, 3, 4, 5};

    printf("Address of first element using arr: %p\n", (void*)arr);
    printf("Address of first element using &arr[0]: %p\n", (void*)&arr[0]);
    printf("Address of array using &arr: %p\n", (void*)&arr);

    printf("Size of arr using sizeof(arr): %zu\n", sizeof(arr));
    printf("Size of &arr[0] using sizeof(&arr[0]): %zu\n", sizeof(&arr[0]));
    printf("Size of &arr using sizeof(&arr): %zu\n", sizeof(&arr));

int a[5] = {0, 0, 0, 0, 0};
int *pa = &a[1]; //rather than &a[0] ...
a[3] = 42;	//need to update the heap
if (pa[2] == 42) {
    printf("pa[2] is 42");
} else {
    printf("pa[2] is NOT 42");
}

    return 0;
}