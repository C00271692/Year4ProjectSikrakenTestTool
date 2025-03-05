#include <stdio.h>
int ug;
struct Point {
    int x;
    int y;
};
struct Point pg; 

void test() {
    struct Point p;  // Uninitialized local struct
    printf("in test() p.x = %d, p.y = %d\n", p.x, p.y);
    char x[10] = {};
    printf("in test(), x[0] = %d, x[9] = %d\n", x[0], x[9]); 
}

int main() {
    char x[10] = {};
    printf("local x[0] = %d, x[9] = %d\n", x[0], x[9]); 
    test();
    int u;
    printf("local u = %d; global u = %d\n", u, ug);
    printf("global p.x = %d, p.y = %d\n", pg.x, pg.y);
    return 0;
}