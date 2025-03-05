typedef int myType; // Ordinary identifier
struct myType { // Tag
    int myType; // Member
};

struct myType2 { // Tag
    int myType; // Member
};

void myFunction() { // Ordinary identifier
    myType var = 10; // var Ordinary identifier
    goto var; // var Label
var:
    var++;
}

int identVar;
typedef int identType;
enum identVar 
    {identEnumLit1, 
     identEnumLit2
    };

identType identFun(int identVar) {
    if (identVar==42) return 42;
    else return 0;
}

int  main() {
    identVar = 42;
    identFun(identVar);
    struct myType s; // Tag
    struct myType2 t; 
    s.myType = 20; // myType is a Member
    t.myType = 02; // myType is a different Member
    myFunction(); // Ordinary identifier
    return 0;
}