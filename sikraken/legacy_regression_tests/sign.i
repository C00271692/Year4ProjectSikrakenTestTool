





















int y = 5;
int check_global() {
    return y;
}








    
    
    
    
    

    
    

    
    

    
    
    
    

    
    
    

    
    
    
    


    
    
    
    
    
    












int abc(int x,int y) {
    x = x + y;
    if (x > 0) {
        return 1;
    }
    x = x + 1;
    if(x >= 1) {
        return x;
    }
    return 42;
}












int check_password(int *buf) {
  if (buf[0] == 15 && buf[1] == 1 && buf[2] == 99 && buf[3] == -5 && buf[4] == 0)
    return 1;
  return 0;
}














