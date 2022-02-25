import processing.video.*;
VideoExtractor videoExtractor; 

PVector centerOfMassFromVideoExtractor;

void setup()
{

  fullScreen( P3D,2);
  background(0);
  
  videoExtractor = new VideoExtractor(1650, 450, this);
  videoExtractor.startSketch();
}


void draw()
{
  background(0);
  
  //this white rectangle wrapping the sketch is used to control 
  //where to draw the ROI
  noFill();
  stroke(255,210);
  rectMode(CORNER);
  rect(0,0,displayWidth,displayHeight);
  
  
  if(null != centerOfMassFromVideoExtractor)
  {
     rectMode(CENTER);
     noFill();
     stroke(255,255);
     rect(centerOfMassFromVideoExtractor.x,centerOfMassFromVideoExtractor.y,50,50);
  }
  
}
 
 
