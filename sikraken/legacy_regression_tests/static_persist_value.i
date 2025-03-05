


int counter() {
    static int x = 0; 
    x++;
    return x;
}

int static_persist_value() {
    return counter() + counter() + counter(); 
}
