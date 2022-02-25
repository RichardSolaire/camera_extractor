import javax.swing.JFrame;
import gab.opencv.*;
import java.awt.Rectangle;

class VideoExtractor extends PApplet
{
  private static final int CAMERA_INDEX = 0; //change according to your camera index
  int SKETCH_MODE = 0; //0 camera mode, 1 rgb registration, 2 start analyzing
  int pAppletWidth, pAppletHeight;
  PApplet mainSketch;
  Capture cam;
 
  PVector ROIdownright;
  PVector ROIupperleft;
  float ROIWidth;
  float ROIHeight;
  PVector firstClickMousePosition;

  OpenCV opencv;
  OpenCV opencv2;
  OpenCV opencv3;

  ArrayList<PVector> interestingPoints = new ArrayList<PVector>();
  ArrayList<PVector> interestingPointsSizes = new ArrayList<PVector>();
  PVector centerOfInterestingPoints; //this is the mass center of the last series of interestingPoints
  PVector centerOfInterestingPointsNormalizedInSketch; //the ROI INTERACTION normalized in the sketch window coordinates

  PImage imgROIfromCamera;
  PImage imgROIfromCamera2;
  PImage imgROIfromCamera3; 
  PImage imgROIfromCamera4; 

  PImage anaylisisOutputImage;
  //the values used for the registration of points to detect
  float rVal, bVal, gVal;

  public VideoExtractor(int pAppletWidth, int pAppletHeight, PApplet mainSketch)
  {
    this.pAppletWidth = pAppletWidth; 
    this.pAppletHeight = pAppletHeight; 
    this.mainSketch = mainSketch;
  }

  public void startSketch()
  {
    runSketch(new String[]{}); /*this starts the sketch in a new jframe */
  }

  private void debugCameras()
  {

    String[] cameras = Capture.list();
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(i+","+cameras[i]);
      }
    }
  }

  private void initCamera()
  {
    String[] cameras = Capture.list(); 
    cam = new Capture(this, cameras[CAMERA_INDEX]);
    cam.start();
  }
  void setup()
  {
    surface.setSize(this.pAppletWidth, this.pAppletHeight);
    //debugCameras();
    initCamera();
  }


  void draw()
  {
    strokeWeight(1);
    if (SKETCH_MODE == 0)
    {
      if (cam.available() == true) {
        cam.read();
      }
      PImage tCam = cam.get();
      // println(width,height);
      //tCam.resize(1280, 720);
      image(tCam, 0, 0);

      if (null != firstClickMousePosition)
      {
        rectMode(CORNER);
        noFill();
        stroke(255, 0, 0);
        strokeWeight(3);
        rect(firstClickMousePosition.x, firstClickMousePosition.y, 
          mouseX-firstClickMousePosition.x, mouseY-firstClickMousePosition.y);
      }
    } else if (SKETCH_MODE == 2)
    {
      textSize(12);
      textAlign(CENTER);
      stroke(255, 255);
      if (null != imgROIfromCamera)
      {
        background(0);
        image(imgROIfromCamera, 0, 0);
        text("ROI cam. with only white", ROIWidth*.5-100, ROIHeight+20);
      }
      if (null != imgROIfromCamera2)
      {
        image(imgROIfromCamera2, ROIWidth, 0);
        text("ROI cam. with no white", ROIWidth+ROIWidth*.5-50, ROIHeight+20);
      }
      if (null != imgROIfromCamera3)
      {
        image(imgROIfromCamera3, ROIWidth*2, 0);
        text("Morphological operators", 2*ROIWidth+ROIWidth*.5-40, ROIHeight+20);
      }
      if (null != imgROIfromCamera4)
      {
        image(imgROIfromCamera4, ROIWidth*3, 0);
        text("Bounding box", 3*ROIWidth+ROIWidth*.5-30, ROIHeight+20);
      }

      //run the analysis
      this.interestingPoints  = analyzeROICamera(); 
      if (interestingPoints.size() > 0  ) //draw interesting points
      {
        for (int i = 0; i< interestingPoints.size(); i++)
        {
          pushMatrix();   
          fill(255, 0, 0, 255);
          stroke(255, 0, 0, 255); 
          ellipse(3*ROIWidth+interestingPoints.get(i).x, interestingPoints.get(i).y, interestingPointsSizes.get(i).x, interestingPointsSizes.get(i).y);
          popMatrix();
        }
      }


      this.centerOfInterestingPoints = findCenterOfMass(interestingPoints); 
      if (this.centerOfInterestingPoints != null)
      {
        pushMatrix();    //draw center of mass
        noFill();
        stroke(0, 255, 0, 255); 
        ellipse(3*ROIWidth+centerOfInterestingPoints.x, centerOfInterestingPoints.y, 50, 50);
        popMatrix();
      }

      this.centerOfInterestingPointsNormalizedInSketch =  normalizeROIInterestingPoint(this.centerOfInterestingPoints);
      //end of analysis, if we found something...
      if ( this.centerOfInterestingPointsNormalizedInSketch != null)
      {
        //here we interact with the main sketch
        //updateRotationsVelocity((int) centerOfInterestingPointsNormalizedInSketch.x, (int) centerOfInterestingPointsNormalizedInSketch.y);
        //updateRotationsVelocity((int) centerOfInterestingPointsNormalizedInSketch.x, (int) centerOfInterestingPointsNormalizedInSketch.y);
      }
    }
  }


  PVector normalizeROIInterestingPoint(PVector toNormalize)
  {
    if (null == toNormalize) return null;


    PVector normalized;
    float normalizedX = map(toNormalize.x, 0, ROIWidth, 0, mainSketch.width);
    float normalizedY = map(toNormalize.y, 0, ROIHeight, 0, mainSketch.height);
    normalized = new PVector(normalizedX, normalizedY);
    return normalized;
  }


  public PVector findCenterOfMass(ArrayList<PVector> points)
  {
    if (points.size() == 0)
      return null;

    PVector centerOfMass = new PVector(0, 0);
    //int newton = (int)(points.size() * (points.size() -1) / 2.0);
    /*for (int i = 0; i< points.size() -1; i++)
     {
     for (int j = i+1; j< points.size(); j++)
     {
     centerOfMass.add(points.get(j).copy().sub(points.get(i)).mult(1.0/newton));
     }
     }*/
    for (int i = 0; i< points.size(); i++)
    {
      centerOfMass.add(points.get(i));
    }
    centerOfMass = centerOfMass.mult(1.0/points.size());





    return centerOfMass;
  }


  ArrayList<PVector> analyzeROICamera()
  {
    ArrayList<PVector> interestingPoints = new ArrayList<PVector>();
    //work only in camera frame in ROIupperleft e ROIdownright boundaries
    if (cam.available()) {
      //read from camera
      cam.read();
      PImage imgtT = cam.get();
      //extract the ROI from camera
      this.imgROIfromCamera = imgtT.get((int)ROIupperleft.x, (int)ROIupperleft.y, (int)ROIWidth, (int)ROIHeight); 
      this.imgROIfromCamera2 = imgtT.get((int)ROIupperleft.x, (int)ROIupperleft.y, (int)ROIWidth, (int)ROIHeight);

      //load ROI from camera in opencv
      opencv.loadImage(imgROIfromCamera);
      //image processing
      //eliminate all non white pixels (we are working in rgb space)
      opencv.threshold(200);
      this.imgROIfromCamera = opencv.getSnapshot();
      //from the original roi image from camera, we substract
      //all the white pixels 
      this.imgROIfromCamera2.loadPixels();  
      for (int i = 0; i< imgROIfromCamera.pixels.length; i++)
      {
        if (green(imgROIfromCamera.pixels[i]) > 0 && blue(imgROIfromCamera.pixels[i]) > 0 
          && red(imgROIfromCamera.pixels[i]) > 0 ) 
          this.imgROIfromCamera2.pixels[i] = color(#000000);
      }
      this.imgROIfromCamera2.updatePixels();
      //now we want to filter only the pixels in the hue (or rgb) range
      //for the target
      opencv2.loadImage(this.imgROIfromCamera2); 
      opencv2.useColor();
      PImage temp = opencv2.getSnapshot();
      temp.loadPixels();
      for (int i = 0; i< temp.pixels.length; i++)
      {
        if ( abs(red(temp.pixels[i])-rVal) > 10 || abs(green(temp.pixels[i])-gVal) > 10 || abs(blue(temp.pixels[i])-bVal) > 10) 
          temp.pixels[i] = color(#000000);
        else temp.pixels[i] = color(#ffffff);
      }
      temp.updatePixels();
      opencv2.loadImage(temp);
      this.imgROIfromCamera2 = opencv2.getSnapshot();
      //morphological operators
      opencv2.setGray(opencv2.getR().clone());
      opencv2.blur(3);
      opencv2.dilate(); 
      opencv2.erode(); 


      this.imgROIfromCamera3 = opencv2.getSnapshot();
      imgROIfromCamera4 = imgtT.get((int)ROIupperleft.x, (int)ROIupperleft.y, (int)ROIWidth, (int)ROIHeight);
      //find the biggest contour
      ArrayList<Contour> contours = opencv2.findContours(true, true); 

      for (int i = 0; i< contours.size(); i++)
      {
        Contour biggestContour = contours.get(i);
        Rectangle r = biggestContour.getBoundingBox();
        interestingPointsSizes.add(new PVector(r.width, r.height));
        interestingPoints.add(new PVector(r.x + r.width/2, r.y + r.height/2));
      }
    }

    return interestingPoints;
  }

  void registraROICamera()
  {
    ROIupperleft = firstClickMousePosition.copy();
    ROIdownright = new PVector(mouseX, mouseY); 
    ROIWidth = ROIdownright.x - ROIupperleft.x;
    ROIHeight = ROIdownright.y - ROIupperleft.y;
  }

  void mousePressed()
  {
    if (SKETCH_MODE == 0)
    { 
      if (firstClickMousePosition == null)
        firstClickMousePosition = new PVector(mouseX, mouseY);
        
    } else if (SKETCH_MODE == 1)
    {
      color c = get(mouseX, mouseY);
      println("r: " + red(c) + " g: " + green(c) + " b: " + blue(c)); 
      rVal = red(c);
      gVal = green(c);
      bVal = blue(c);
    }
  }


  void mouseReleased()
  {
    if (SKETCH_MODE == 0)
    {
      registraROICamera();
      firstClickMousePosition = null;
    }
  }

  void keyPressed()
  {
    switch(key )
    {  
    case '0': 
      SKETCH_MODE = 0; 
      break;
    case '1': 
      SKETCH_MODE = 1; 
      break;
    case '2':  
      SKETCH_MODE = 2;  
      this.opencv = new OpenCV(this, (int)ROIWidth, (int)ROIHeight);
      this.opencv.useColor();
      this.opencv2 = new OpenCV(this, (int)ROIWidth, (int)ROIHeight);
      this.opencv2.useColor();
      this.opencv3 = new OpenCV(this, (int)ROIWidth, (int)ROIHeight);
      this.opencv3.useColor();
      break;
    }
  }
}
