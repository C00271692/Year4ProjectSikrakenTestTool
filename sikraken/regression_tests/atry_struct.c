extern int __VERIFIER_nondet_int();

struct struct_of_struct {
    int x, y, z, t; 
    struct {
        int anon;
    } inner;
    struct {
        int anon;
    };
};

struct point {
    int x, y, z, t; 
    float weight;
} p78 = {1,2,3,4,4.004}, p79 = {1};    //p78 is fully initialised, p79 only has its first field set to 1, the rest is 0

struct point2 {
    int x, y, z, t;
    float weight;
} p1 = {1, 2, 3, 4, 67.0}, p2;           //all members of p1 and p2 to 0 by default because they are globals
struct point3;  //forward declaration
struct point3 {
    int x, y, z, t;
    float weight;
};
struct {        //anonymous declaration has no tag
    int x, y, z, t;
    float weight;
} anon1 = {1, 2, 3, 4, 67.0}, anon2;

int a = 1;

typedef struct plot plot;   //typedef of a forward declaration
struct plot {
    int x, y;
};
plot p = {10, 20};  // Works due to typedef


typedef struct {
    int n;
}S; //S is a typedef to an anonymous struct

S Sx;       //an object of type struct
/*
S Ax[5];    //an array of struct

int marks[10];

typedef struct Address {
    char city[50];
    int zip;
} Address;
typedef struct Person {
    char name[50];
    int age;
    Address address;  // No need for 'struct Address'
} Person;

//Person p = {"Alice", 25, {"Wonderland", 12345} };   //inner initialiser are string to be handled later

typedef struct {
    int x, y;
} Point;    //upper case P does not interfere with other anonymous struct point
typedef Point PointArray[10];  // PointArray is an array of 10 Points
PointArray points = {{1, 2}, {3, 4}};  // Array of points: only the first 2 points are initialised


typedef struct Node Node;   //Node is a typedef to struct Node which is a forward declaration
struct Node {               //the struct Node is declared
    int value;
    Node *next;             // Pointer to the same struct type using the earlier typedef
};
Node n = {10, 0};
*/

int main(void) {
    anon2 = anon1;
    struct point2 p3 = p1;
    int i = 0;
    struct point_1 { 
      int x, y, z, t; 
      float weight;
    } p78_1 = {1,2,3,4,4.004}, p79_1 = {1};    //p78_1 is fully initialised, p79_1 only has its first field set to 1, the rest is 'uninitiased'
    int gy;
    gy = p79_1.y;           //gy is uninitialised
    if (gy == __VERIFIER_nondet_int()) i--; 
    i++;
    if (p78_1.x == 1 && p79_1.x == 1 && p78.x == 1 && p79.x == 1) i++;  //always true
    else i--;                       //unreachable
    if (p79.y == 0) i++;            //always true
    else return 1;                  //unreachable
    float fl = p78.x;  //check that casting is called (int to float)
    int gh = p.x + p.y;
    if (gh == __VERIFIER_nondet_int()) i++;
    else i--;
    S x;
    x.n = __VERIFIER_nondet_int();
    if (x.n == 99) i++;
    else i--;
    struct point s1;
    struct point s2 = {1, 2, 3, 4, 42.42};  //list of initialisers can only be used at declaration time
    struct point s3 = {1, 2, 3};    //only partial initialisations is allowed: remaining fields are initialised to 0
    s1.x = __VERIFIER_nondet_int();
    if (s1.x == -5) i++;
    else i--;
    return 0;
}
