import processing.video.*;

  
 
VideoExtractor videoExtractor; 
int NUM_COLS = 40;
int NUM_ROWS = 40; 

Element[][] elements = null;
void setup()
{

  //size(displayWidth, displayHeight, P3D);
  fullScreen( P3D,2);
  //fullScreen();
  //surface.setLocation(50, 50);
  background(0);
 
  initElements();

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
   
  
  updateRotations();
  drawAllElements();
  
  
 
}
 

void mouseDragged()
{
  updateRotationsVelocity(mouseX,mouseY);
}


void keyPressed()
{
   
}  
