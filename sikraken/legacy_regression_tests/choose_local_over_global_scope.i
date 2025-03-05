




int x = 1;
int choose_local_over_global_scope() {
    int x = 99;
    int X = 58;
    x = -x;
    return x;
}
