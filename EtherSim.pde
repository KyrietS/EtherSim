Grid grid;
int mode = 1;
int timer = 0;
boolean pause = true;

int attempts = 0;
int successes = 0;
int collisions = 0;
int updates = 0;

int UPDATES_PER_SECOND = 2;
float TALKINESS = 0.5; // Gadatliwość. Szansa na chęć gadania, gdy kanał jest pusty.

void setup() {
  frameRate(120);
  size( 1225, 805 );
  initializeConductor();
}

void draw() {
  if( timer * UPDATES_PER_SECOND >= frameRate && !pause ) {
    timer = 0;
    grid.update();
    updates++;
  }
  
  background( 200 );  
  
  grid.show();
  showGUI();
  
  timer++;
}

void showGUI() {
  fill(0);
  rect(0,0,width, Tile.HEIGHT);
  fill(255);
  textSize(22);
  int textY = 25;
  // --- TRYB
  String modeStr = "Tryb ";
  switch( mode ) {
    case 1: modeStr += "(1): Przewodnik"; break;
    case 2: modeStr += "(2): Absorber"; break;
    case 3: modeStr += "(3): Nadajnik"; break;
    case 4: modeStr += "(4): Sygnał"; break;
  }
  text( modeStr, 4, textY );
  // --- Stats
  String info = "Dł. przewodnika: " + (grid.getPropagationLength() / 2 - 1);
  //float prob = float(int(TALKINESS * 1000000 / grid.getPropagationLength() )) / 1000000;
  info += " | Gadatliwość: " + float(int(TALKINESS*1000))/1000;
  
  text( info, 400, textY );
  
  if( pause )
    text("PAUZA", width - 170, textY);
  // --- UPDATES_PER_SECOND
  String speedStr = "x" + UPDATES_PER_SECOND;
  text( speedStr, width - 80, textY );
  
  fill(0);
  stroke(0);
  rect( 0, height - Tile.HEIGHT*9, Tile.WIDTH*5, Tile.HEIGHT * 9 );
  String stats = "PRÓBY\n";
  stats += attempts + "\n";
  stats += "SUKCESY\n";
  stats += successes + "\n";
  stats += "KOLIZJE\n";
  stats += collisions + "\n";
  stats += "INTERWAŁ\n";
  stats += updates;
  fill(255);
  textSize(22);
  text( stats, 2, height - Tile.HEIGHT*8 );
}

void initializeConductor() {
  grid = new Grid();
}

void mousePressed() {
  
  if( mode == 1 && mouseButton == LEFT ) {
    grid.putConductor(mouseX,mouseY);
  }
  if( mode == 2 && mouseButton == LEFT ) {
    grid.putAbsorber(mouseX, mouseY);
  }
  if( mode == 3 && mouseButton == LEFT ) {
    grid.putEmitter(mouseX,mouseY);
  }
  if( mode == 4 && mouseButton == LEFT ) {
    grid.emit(mouseX,mouseY);
  }
  
  if( mouseButton == RIGHT ) {
      grid.putEther(mouseX,mouseY);
    }
}

void keyPressed() {
  if( key == '1' )
    mode = 1;
  if( key == '2' )
    mode = 2;
  if( key == '3' )
    mode = 3;
  if( key == '4' )
    mode = 4;
  if( key == ' ' )
    pause = !pause;
    
  if( key == '+' )
    UPDATES_PER_SECOND++;
  if( key == '-' )
    UPDATES_PER_SECOND--;
  if( keyCode == UP )
    TALKINESS = TALKINESS + 0.01 > 1 ? 1 : TALKINESS + 0.01;
  if( keyCode == DOWN )
    TALKINESS = TALKINESS - 0.01 < 0 ? 0 : TALKINESS - 0.01;
  if( keyCode == RIGHT )
    TALKINESS = TALKINESS + 0.1 > 1 ? 1 : TALKINESS + 0.1;
  if( keyCode == LEFT )
    TALKINESS = TALKINESS - 0.1 < 0 ? 0 : TALKINESS - 0.1;
}

void mouseMoved() {
  grid.hover( mouseX, mouseY );
}

void mouseDragged() {
  mouseMoved();
  mousePressed();
}
