

# CameraExtractor - Processing (java) 


![img](https://github.com/sitodav/camera_extractor/blob/develop/images/0.png?raw=true "Title")


## Features & limitations (for the moment)
- A little pluggable sketch to allow user to interact with a projected sketch, using a laser (or a hand, or whatever object you prefer)
- You register what kind of point you want to track using the RGB space
- There are some glitches due to illumination that I plan to fix (making it more robust)
- The main sketch should only work with white drawing (stroke and fill)


## What you need
- A cheap camera (the better the model, the better the results), mounted on the projector (or in a place where can record the projection)
- A projector
- At least one monitor (to control the demo) separated from the projector (the main sketch should run in fullscreen on the projector)

## How it works
You have a main sketch. And you have the videoextractor class.
In your main sketch you have to draw ONLY with the color white.
The main sketch runs on the projector, so it's projected on the wall.
The analysis (and the user interaction for ROI and RGB registration) happens on a second sketch that runs in another thread on secondary papplet.
The camera records what is projected, and analyze only what happens in the ROI (the ROI is selected from the user)
The videoextractor eliminate the white pixels from the ROI (these should be from the main sketch projection), and detects the most similars to the RGB values selected from the user.
The center of mass of this point is returned, normalized in the main sketch size/coordinas
The main sketch can use the center of mass from the videoextractor papplet.
 

 

## Use

In the setup function, the second parameter to fullScreen() is the index of the projector (to get it right you have
to try it out, on my system sometimes it's 2, others it's 1

 ####Java　
```java

PVector centerOfMassFromVideoExtractor; //this is set from the videoextractor


//MAIN SKETCH
void setup()
{

  fullScreen( P3D,2);  
  background(0);
  
  videoExtractor = new VideoExtractor(1650, 450, this); 
  videoExtractor.startSketch();
}
```

Note that in the main sketch , for the demo, I draw a white rectangle wrapping the main sketch.
This is used to understand, on the secondary/control sketch, what is the sketch inside of what the camera is recording.

 ####Java　
```java
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
```

When you start the sketch, on the second window (not the one of the main sketch)
you have 3 working modes (the starting one is 0)
0: Register ROI 
1: Register what RGB color detect 
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

`<my generative coding>` : <https://linktr.ee/stickyb1t>



###
