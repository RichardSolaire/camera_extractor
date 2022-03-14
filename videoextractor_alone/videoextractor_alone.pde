import processing.video.*;

  
 
VideoExtractor videoExtractor; 
int NUM_COLS = 40;
int NUM_ROWS = 40; 

 
void setup()
{

  //size(displayWidth, displayHeight, P3D);
  fullScreen( P3D,1);
  //fullScreen();
  //surface.setLocation(50, 50);
  background(0);
  
 

  videoExtractor = new VideoExtractor(1650, 450, this);
  videoExtractor.startSketch();
}


void draw()
{
  background(0);
  noFill();
  stroke(255,210);
  rectMode(CORNER);
  rect(0,0,displayWidth,displayHeight);
   
 
  
  
 
}
 
