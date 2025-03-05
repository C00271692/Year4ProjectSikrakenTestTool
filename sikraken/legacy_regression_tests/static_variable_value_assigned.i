


int counter() {
    static int x = 10;
    x++;
    return x;
}

int static_variable_value_assigned() {
    return counter() + counter(); 
}
