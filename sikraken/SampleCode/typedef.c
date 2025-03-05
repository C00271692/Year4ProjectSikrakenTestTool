struct table;   //struct table is declared
typedef struct table table; //typedef is used to define table as struct table
union anonymous_62146 {
    int *table;  // table is a member, just an identifier
    int pat;
};

struct table {  //struct table is defined
    const char *name;
    int type;
    int value;
};
static const table universal_time_zone_table_200015[4]; //table is a typedef name denoting struct table
static table tt; //table is a typedef name denoting struct table
table t3;
static table ttt; //table is a typedef name denoting struct table
typedef int my_int;

int a = 1;
int y = (my_int)1;  //my_int is a typedef name

typedef struct node {
 int is_typedef_name;
 char* name;
 struct node* next;
} list_node;
void free_list_node(list_node* node) {
     // list_node* temp = node;
 while (node != ((void *)0)) {
   // int gh = 0;
  list_node* temp = node;
 }
}

typedef int my_int2;
int hello0(int my_int2); //function prototype: should not define my_int2 as shadowing the typedef name

int hello0(int my_int3) {
    return 0;
}

int hello1(my_int2 *y) { 
    while (y != ((void *)0)) {
        my_int2* z = y; 
        int a = 1;
        int my_int = 42;        //shadowing of typedef name my_int
    }
    //int x = (my_int);   //causes parser error because shadowing is not implemented
    return 0;
}

int hello2(table tt) { //table is the typedef
    typedef char my_int;
    return 0;
}

int main() {
    int table = 0; //table is a variable, not a typedef name
    //table t;  //gcc error: conflict as table represent a var and a typedef in the same scope and the same namespace
    //int x = 6 + table; //causes parser error because shadowing is not implemented
    table : a = 6; //table is a label, not a typedef name
    //return table; //causes parser error because shadowing is not implemented
}