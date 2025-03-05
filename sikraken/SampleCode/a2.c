#include <stdio.h>

struct Point {
    int x, y;
};

struct Point pt_fn(int x, int y) {
    struct Point result = {x+1, y};
    return result;
}

int main() {
    struct Point p = pt_fn(10, 20);
    printf("Point: (%d, %d)\n", p.x, p.y);
    struct Point a[10];
    printf("a[2]: (%d, %d)\n", a[2].x, a[2].y);
    return 0;
}
