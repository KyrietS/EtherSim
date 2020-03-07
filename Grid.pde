class Grid {
  
  Tile[][] tiles;
  
  Grid() {
    tiles = new Tile[ width / Tile.WIDTH ][ height / Tile.HEIGHT ];
    for( int i = 0; i < tiles.length; i++ )
      for( int j = 0; j < tiles[i].length; j++ ) {
        tiles[i][j] = new EtherTile( this, i, j );
      }
  }
  
  void show() {
    for( Tile[] row : tiles )
      for( Tile t : row )
        t.show();
  }

  void update() {
    for( Tile[] row : tiles )
      for( Tile t : row )
        t.update();
    for( Tile[] row : tiles )
      for( Tile t : row )
        t.apply();
  }

  void hover( int x, int y ) {
    int i = xToi( x );
    int j = yToj( y );
    
    for( Tile[] row : tiles )
      for( Tile t : row )
        t.isHover = false;
        
     tiles[i][j].isHover = true;
  }
  
  void emit( int x, int y ) {
    int i = xToi( x );
    int j = yToj( y );
    if( tiles[i][j] instanceof EmitterTile )
      ((EmitterTile)tiles[i][j]).onClick();
    else
      tiles[i][j].send( new Signal(0) );
    tiles[i][j].apply();
  }
  void emitAround( Signal s, int i, int j ) {
    if( i > 0 )
      if( i-1 != s.prevI || j != s.prevJ )
        tiles[i-1][j].send( new Signal(s, i, j) );
    if( j > 0 )
      if( i != s.prevI || j-1 != s.prevJ )
        tiles[i][j-1].send( new Signal(s, i, j) );
    if( i < tiles.length )
      if( i+1 != s.prevI || j != s.prevJ )
        tiles[i+1][j].send( new Signal(s, i, j) );
    if( j < tiles[0].length )
      if( i != s.prevI || j+1 != s.prevJ )
        tiles[i][j+1].send( new Signal(s, i, j) );
  }
  
  void putEmitter( int x, int y ) {
    int i = xToi( x );
    int j = yToj( y );
    tiles[i][j] = new EmitterTile( this, i, j );
  }
  void putAbsorber( int x, int y ) {
    int i = xToi( x );
    int j = yToj( y );
    tiles[i][j] = new AbsorberTile( this, i, j );
  }
  void putConductor( int x, int y ) {
    int i = xToi( x );
    int j = yToj( y );
    tiles[i][j] = new ConductorTile( this, i, j );
  }
  void putEther( int x, int y ) {
    int i = xToi( x );
    int j = yToj( y );
    tiles[i][j] = new EtherTile( this, i, j );
  }
  
  int getPropagationLength() {
    int result = 1;
    for( Tile[] row : tiles )
      for( Tile t : row )
        if( t instanceof ConductorTile )
          result++;
    return result * 2;
  }
  
  private int xToi( int x ) {
    return x / Tile.WIDTH;
  }
  private int yToj( int y ) {
    return y / Tile.HEIGHT;
  }

}
