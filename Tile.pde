
abstract class Tile {
  
  static final int WIDTH = 35; 
  static final int HEIGHT = 35; 
  
  int x, y;
  int i, j;
  Grid grid;
  boolean isHover = false;
  
  Tile( Grid grid, int i, int j ) {
    this.grid = grid;
    this.i = i;
    this.j = j;
    this.x = i * WIDTH;
    this.y = j * HEIGHT;
  }
  void show() {
    if( isHover ) {
      strokeWeight( 3 );
    } else {
       strokeWeight( 1 );
    }
     
     showTile();
  }
  void update() {}
  void apply() {}
  
  abstract void showTile();
  void send( Signal s ) {}
  
}
// ------------------------------------------------------------
enum EmitterMode{ LISTEN, SEND, COLLISION, FIX, DEAD }
class EmitterTile extends Tile {
  
  EmitterMode mode = EmitterMode.LISTEN;
  int signalsEmitted = 0;
  int fixAttempt = 0;
  int wait = 0;
  int waitCounter = 0;
  boolean lineBusy = false;
  
  EmitterTile( Grid grid, int i, int j ) {
    super( grid, i, j );
  }
  
  void apply() {
    switch( mode ) {
      case LISTEN: listenUpdate(); break;
      case SEND: sendUpdate(); break;
      case COLLISION: collisionUpdate(); break;
      case FIX: fixUpdate(); break;
    }
    lineBusy = false;
  }
  // Kliknięcie w emitter
  void onClick() {
    switch( mode ) {
      case LISTEN: setMode( EmitterMode.SEND ); break;
      case SEND: setMode( EmitterMode.LISTEN ); break;
      case COLLISION: setMode( EmitterMode.LISTEN ); break;
      case FIX: setMode( EmitterMode.SEND ); break;
      case DEAD: setMode( EmitterMode.LISTEN ); break;
    }
  }
  
  void listenUpdate() {
    if( wait == 1 || random(0, 1) < TALKINESS / grid.getPropagationLength() ) {
      wait = 1;
      if( !lineBusy )
        setMode( EmitterMode.SEND );
    }
  }
  
  void fixUpdate() {
    if( waitCounter > 0 )
      waitCounter--;
    else if( !lineBusy )
      setMode( EmitterMode.SEND ); // Cisza. Zacznij gadać      
  }
  
  void collisionUpdate() {
    Signal signal = new Signal(-1); // Kontynuuj wysyłanie sygnału zakłócającego
    signal.noisy = true;
    grid.emitAround(signal,i,j);
    signalsEmitted++;
    if( signalsEmitted >= grid.getPropagationLength() )
      setMode( EmitterMode.FIX );
  }
  void sendUpdate() {
    Signal signal = new Signal(1);
    grid.emitAround(signal,i,j);
    signalsEmitted++;
    if( signalsEmitted >= grid.getPropagationLength() ) {
      setMode( EmitterMode.LISTEN );
      successes++;
    }
  }
  
  void showTile() {
    stroke(#7a7a7a);
    fill( #f6ff00 );
    rect( x, y, WIDTH, HEIGHT );
    
    switch( mode ) {
      case LISTEN: fill(#0c9b00); break;
      case SEND: fill(#0066ed); break;
      case COLLISION: fill(#FF0000); break;
      case FIX: fill(#ff9000); break;
      case DEAD: fill(#000000); break;
    }
    rect( x, y, WIDTH, 8 );
    
    if(  wait > 0 && waitCounter > 0 ) {
      fill(#0066ed);
      // Pasek postępu oczekiwania
      rect( x, y+HEIGHT-4, WIDTH * (float(wait*grid.getPropagationLength() - waitCounter) / (wait*grid.getPropagationLength())), 4 );
      // Wypisywanie cyfry z wylosowanym interwałem
      fill( 0 );
      textSize( 14 );
      text( wait, x + WIDTH/2 - 3, y + HEIGHT/2 + 8 );
    }
  }
  
  void setMode( EmitterMode mode ) {
    if( mode == EmitterMode.LISTEN ) {
      fixAttempt = 0;
      wait = 0;
      waitCounter = 0;
    }
    if( mode == EmitterMode.SEND ) {
      attempts++;
      signalsEmitted = 0;
    }
    if( mode == EmitterMode.FIX ) {
      if( fixAttempt >= 10 ) // Jeśli kolizja powtórzy się 10 razy, to umrzyj :'(
      {
        setMode( EmitterMode.DEAD );
        return;
      }
        
      fixAttempt++;
      //int range = (int)pow(2, fixAttempt); // 1, 2, 4, 8, 16...
      int range = fixAttempt + 1;
      wait = (int)random(0, range + 1); // liczba {0, ... , range
      waitCounter = wait * grid.getPropagationLength();
    }
    if( mode == EmitterMode.COLLISION )
      collisions++;
    this.mode = mode;
  }
  
  // Jeśli ktoś wywoła tę metodę w stanie SEND, to znaczy, że doszło do kolizji.
  void send( Signal s ) {
    lineBusy = true;
    if( mode == EmitterMode.SEND ) {
      setMode( EmitterMode.COLLISION );
    }
  }
}
// ------------------------------------------------------------
class ConductorTile extends Tile {
  
  ArrayList<Signal> signals = new ArrayList<Signal>();
  ArrayList<Signal> prepared = new ArrayList<Signal>();
  
  ConductorTile( Grid grid, int i, int j ) {
    super( grid, i, j );
  }
  
  void update() {
    if( signals.size() > 1 ) // Jeśli jest więcej niż jeden sygnał, to wszystkie stają się zakłócone
      for( Signal s : signals )
        s.noisy = true;
        
    for( Signal s : signals )
      grid.emitAround( s, i, j );
  }
  
  void apply() {
    
    // Gdy sygnały się miną bez nałożenia na siebie w danym interwale, to też muszą być zagłuszone
    for( Signal s1 : signals )
      for( Signal s2 : prepared )
        if( s1.prevI != s2.prevI || s1.prevJ != s2.prevJ )
          s2.noisy = true;
    
    signals.clear();
    signals = (ArrayList)prepared.clone();
    prepared.clear();
  }
  
  void showTile() {
    stroke(#7a7a7a);
    if( signals.size() == 0 ) // Kanał pusty
      fill( #c8c8c8 );
    else if( signals.size() == 1 && !signals.get(0).noisy ) // Jeden, niezakłócony sygnał
      fill( #91bbff );
    else // Więcej sygnałów lub zakłócony sygnał
      fill( #5977a8 );
    
    rect( x, y, WIDTH, HEIGHT );
  }
  
  void send( Signal s ) {
    prepared.add( s );
  }
}
// ------------------------------------------------------------
class AbsorberTile extends Tile {
  AbsorberTile( Grid grid, int i, int j ) {
    super( grid, i, j );
  }
  
  void showTile() {
    stroke(#7a7a7a);
    fill( #2d2d2d );
    rect( x, y, WIDTH, HEIGHT );
  }
}
// ------------------------------------------------------------
class EtherTile extends Tile {
  
  EtherTile( Grid grid, int i, int j ) {
    super( grid, i, j );
  }
  
  void showTile() {
    stroke(#7a7a7a);
    fill( #FFFFFF );
    rect( x, y, WIDTH, HEIGHT );
  }
}
