class Signal {
  int id;
  int prevI = -1;
  int prevJ = -1;
  boolean noisy = false;
  Signal( int id ) {
    this.id = id;
  }
  
  Signal( Signal s, int i, int j ) {
    id = s.id;
    prevI = i;
    prevJ = j;
    noisy = s.noisy;
  }
}
