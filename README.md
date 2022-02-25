

# StickyGUI


![img](https://github.com/sitodav/stickyGUI/blob/develop/0.png?raw=true "Title")



## Features

- A little pluggable sketch to allow user to interact with a projected sketch, using a laser (or a hand, or whatever object you prefer)
- It supports interaction with single chars events (like a,b,c,1,2...) and special KeyCode events (like ENTER).
- Sometimes it has some problems with the resizing. It will be fixed in the next release.

 

## Installation
First of all, the sketch requires to download (in Processing) and import the **controP5** library.
In your processing sketch go to **Sketch > Import Library > Add Library**.
Type **controlP5**, select it and install.
Then you can import it going to Sketch > Import Library and selecting it , or using `import controlP5.*; ` in your sketch.

## Use
To use the library, you must copy the plain code contained in the StickyGUI file in your Processing sketch folder (for now it's not shared as jar, but as plain java code).
For example if you Processing sketch is called "Foo", and you have it in the Foo folder, copy the StickyGUI file in it.
Then you can us it right away.


## Example
 A little sketch example that draw the letter associated with the button clicked on the GUI
 ####Java　

```java
/**MAIN SKETCH */
import controlP5.*;
StickyGUI guiApplet;

String whatToPrint = null;
void setup()
{
  size(300,300);
  //WE SET UP THE GUI CONTROLLER
  //INITIALIZING IT WITH ALREADY TWO KEY BINDING EVENTS
  guiApplet = new StickyGUI(new Object[]{ "a", "b", Integer.valueOf(ENTER), Integer.valueOf(SHIFT)  },400,400,4,4,this); 
  guiApplet.startSketch();
 
}

/*THIS IS CLASSIC PROCESSING STUFF ... */
void draw()
{
  background(0);
  if(null != whatToPrint)
  {
     textAlign(CENTER);
     textMode(CENTER);
     stroke(255,255);
     textSize(32);
     text(whatToPrint,width*0.5,height*0.5);
  }
}

//HERE YOU CATCH keyValue AS ALWAYS
void keyPressed()
{ 
  if(keyCode == ENTER)
   whatToPrint= "You Pressed ENTER";
  else if(keyCode == SHIFT)
   whatToPrint= "You Pressed SHIFT";
  else if(key == 'a')
   whatToPrint= "You Pressed a";
  else if(key =='b')
   whatToPrint= "You pressed b";
}
```

 

### Links

`<my generative coding>` : <https://stickyb1t.start.page/>



###
