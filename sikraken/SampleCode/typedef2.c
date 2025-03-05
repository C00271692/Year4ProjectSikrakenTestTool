
int main() {
    struct tab{ 
        const char *name;
        int type;
        int value;
    };
    typedef struct tab table;
    int table = 0;
    table t;
    return table;
}