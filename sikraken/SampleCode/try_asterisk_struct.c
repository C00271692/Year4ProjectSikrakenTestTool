//21 June 2024 testing parser for pointer as a member of a structure
typedef int Money;
Money mo1;
typedef char *String;
int i, j, k;
unsigned short const *aa;
struct b_struct {
    unsigned short const *a;
    Money b;
    unsigned int *c;
};

enum day {
     mon, 
     tue
    };

typedef struct try_struct { //try_struct is structure here
    unsigned short const *a;
    Money b;
    unsigned int c;
} try_struct;   //try_struct is the alias of the typedef, which basically stands for struct try_struct

struct point{
    int X;
    int x;
    int y;
};

void main() {
    typedef long Money;
    struct point pt = {320, 200, 200};
    int tot = pt.X + pt.y + pt.x;
    if (tot > 42) {
        int tot = -1;
        tot = tot + 1;
    }
    tot = tot +1;
}