

# CameraExtractor - Processing (java) 


![img](https://github.com/sitodav/camera_extractor/blob/develop/images/0.png?raw=true "Title")


## Features & limitations (for the moment)
- A little pluggable class to allow user to interact with a projected sketch, using a laser (or a hand, or whatever object you prefer)
- You register what kind of point you want to track using the RGB space
- There are some glitches due to illumination that I plan to fix (making it more robust)
- The main sketch should only work with white drawing (stroke and fill) for now.
- The detection is done using a simple absolute difference between the 3 channels (rgb). As soon as I have time I will try to use something more comples and robus.
- THIS IS AN ALPHA VERSION, AND IT'S SENSIBLE TO ILLUMINATION VARIATIONS. SO YOU WILL PROBABLY HAVE TO PLAY WITH THE PARAMETERS.

## What you need
- A cheap camera (better model, better results), mounted on the projector (or in a place where it can record the projection)
- A projector
- At least one monitor (to control the demo) separated from the projector (the main sketch should run in fullscreen on the projector)

## How it works
You have a main sketch. And you have the videoextractor class.
In your main sketch you have to draw ONLY with the color white.
The main sketch runs on the projector, so it's projected on the wall.
The analysis (and the user interaction for ROI and RGB registration) happens on a second sketch that runs in another thread on secondary papplet.
The camera records what is projected, and analyze only what happens in the ROI (the ROI is selected from the user).
When the sketch starts, you register the part of the camera where the main sketch happens (mode 0) and the
template you want to track (mode 1)
The processor applies several analysis step, and returns the best match for the registered ROI template.

 

 

## Use

In the setup function, the second parameter to fullScreen() is the index of the projector (to get it right you have
to try it out, on my system sometimes it's 2, others it's 1)
 
```java
//MAIN SKETCH

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

```

Note that in the main sketch , for the demo, I draw a white rectangle wrapping the main sketch.
This is used to understand, on the secondary/control sketch, where is the sketch inside of what the camera is recording/displayed on the secondary sketch.

 
```java
PVector displayHere; //this is set by the VideoExtractor class

void draw()
{
  //this is the white rectangle wrapping the primary sketch
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
```

When you start the sketch, on the second window (not the one of the main sketch)
you have 3 working modes (the starting one is 0)
0: Register ROI for the main sketch
1: Register ROI for the region to detect (using cross correlation)
2: Start the analysis and interaction between the videoextractor and the main sketch



## Workflow
Start the sketch.
![img](https://github.com/sitodav/camera_extractor/blob/develop/images/1.png?raw=true "Title")
The default mode is 0 (camera mode).
Drag the mouse to draw a rectangle on the white rectangle wrapping the sketch -> this is our ROI (region of interest) inside the projection.
![img](https://github.com/sitodav/camera_extractor/blob/develop/images/2.png?raw=true "Title")
Be precise
![img](https://github.com/sitodav/camera_extractor/blob/develop/images/3.png?raw=true "Title")
Press 1 on the secondary sketch.
This will set the sketch mode to 1 (RGB registration).
Show what you want to detect to the camera, and use the arrow on the secondary sketch to select a point.
![img](https://github.com/sitodav/camera_extractor/blob/develop/images/4.png?raw=true "Title") 
Press 2 on the secondary sketch to start the analysis/interaction
![img](https://github.com/sitodav/camera_extractor/blob/develop/images/5.png?raw=true "Title")
 

 

### Links
If you liked it, follow me on my socials:

<https://linktr.ee/stickyb1t>



###
