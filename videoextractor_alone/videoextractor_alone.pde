import processing.video.*;

VideoExtractor videoExtractor; 
int NUM_COLS = 40;
int NUM_ROWS = 40; 

 
void setup()
{

 
  fullScreen( P3D,1); 
  background(0);
   
  videoExtractor = new VideoExtractor(1650, 450, this);
  videoExtractor.startSketch();
}


PVector displayHere;

void draw()
{
  background(0);
  noFill();
  stroke(255,210);
  rectMode(CORNER);
  rect(0,0,displayWidth,displayHeight);
  
  PVector t;
  if(null !=(t = displayHere))
  {
     rectMode(CENTER);
     fill(255,10);
     rect(displayHere.x,displayHere.y,200,200);
  }
  
}
