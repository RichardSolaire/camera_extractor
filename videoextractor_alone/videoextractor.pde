import javax.swing.JFrame;
import gab.opencv.*;
import java.awt.Rectangle;

import org.opencv.core.Core;
import org.opencv.core.Core.MinMaxLocResult;
import org.opencv.core.Mat;
import org.opencv.core.Point;
import org.opencv.core.Scalar; 
import org.opencv.imgproc.Imgproc;


class VideoExtractor extends PApplet
{

  private static final int CAMERA_INDEX = 0; //change according to your camera index
  int SKETCH_MODE = 0; //0 primary sketch roi registration, 1 rgb registration, 2 template registration, 3 start analyzing
  int pAppletWidth, pAppletHeight;
  PApplet mainSketch;
  Capture cam;
  float MIN_TEMPLATE_MATCH_ABSVALUE = 140;

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
  PVector centerOfFoundTemplate; //this is the mass center of the last series of interestingPoints
  PVector centerOfFoundTemplateNormalizedInSketch; //the ROI INTERACTION normalized in the sketch window coordinates

  PImage imgROImainSketchFromCam;
  PImage imgROImainSketchFromCamThresholded;
  PImage imgROImainSketchFromCamThresholded2;
  PImage imgROImainSketchFromCamMorphological;

  Mat templateROICVMat;


  PVector redMinMaxFromTemplateROI;
  PVector greenMinMaxFromTemplateROI;
  PVector blueMinMaxFromTemplateROI;
  float rValCenterOfTemplateRoi, bValCenterOfTemplateRoi, gValCenterOfTemplateRoi;

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

    println("\n0: REGISTER ROI PRIMARY SKETCH\n1: REGISTER TEMPLATE ROI\n2: START");
  }


  void draw()
  {
    strokeWeight(1);
    if (SKETCH_MODE == 0 || SKETCH_MODE == 1)
    {
      if (cam.available() == true) {
        cam.read();
      }
      PImage tCam = cam.get();
      this.imgROImainSketchFromCam = tCam;
      // println(width,height);
      //tCam.resize(1280, 720);
      image(tCam, 0, 0);

      if (null != firstClickMousePosition && SKETCH_MODE == 0) // we are registering primary sketch roi
      {
        rectMode(CORNER);
        noFill();
        stroke(255, 0, 0);
        strokeWeight(3);
        rect(firstClickMousePosition.x, firstClickMousePosition.y, 
          mouseX-firstClickMousePosition.x, mouseY-firstClickMousePosition.y);
      } else if (null != firstClickMousePosition && SKETCH_MODE == 1) //we are registering template roi
      {
        rectMode(CORNER);
        noFill();
        stroke(0, 255, 0);
        strokeWeight(3);
        rect(firstClickMousePosition.x, firstClickMousePosition.y, 
          mouseX-firstClickMousePosition.x, mouseY-firstClickMousePosition.y);
      }
    } else if (SKETCH_MODE == 2)
    {
      //JUST DRAWING THE OUTPUTS ************************************************
      textSize(12);
      textAlign(CENTER);
      stroke(255, 255);
      if (null != imgROImainSketchFromCamThresholded)
      {
        background(0);
        image(this.imgROImainSketchFromCamThresholded, 0, 0);
        text("ROI cam. thresholded RGB MIN MAX", ROIWidth*.5-30, ROIHeight+20);
      }
      if (null != imgROImainSketchFromCamThresholded2)
      {
        image(imgROImainSketchFromCamThresholded2, ROIWidth, 0);
        text("ROI cam. thresholded RGB MATCHED", ROIWidth+ROIWidth*.5-50, ROIHeight+20);
      }
      if (null != imgROImainSketchFromCamMorphological)
      {
        image(imgROImainSketchFromCamMorphological, ROIWidth*2, 0);
        text("Morphological operators", 2*ROIWidth+ROIWidth*.5-40, ROIHeight+20);
      }
      if (null != imgROImainSketchFromCam)
      {
        image(imgROImainSketchFromCam, ROIWidth*3, 0);
        text("Candidates and best template", 3*ROIWidth+ROIWidth*.5-30, ROIHeight+20);
      }
      ////////////////////////////
      //REAL ANALYSIS ************************************************
      this.interestingPoints  = detectInterestingPointsInColorSpace(); 

      if (null != interestingPoints && interestingPoints.size() > 0) //if we have found interesting points in the rgb/hue space, we run template matching only on those
      {
        this.centerOfFoundTemplate = findBestTemplateMatchFromPoints(this.interestingPoints);
        for (PVector point : interestingPoints) //just to draw
        {
          noFill();
          strokeWeight(3);
          stroke(255, 0, 0, 200);
          ellipse(ROIWidth*3+point.x, point.y, 10, 10);
        }
      } else //we run template matching on the whole image
      {
        this.centerOfFoundTemplate = findBestTemplateWholeImage();
      }



      if (this.centerOfFoundTemplate != null) //just to draw the best template found
      {
        pushMatrix();    
        noFill();
        stroke(255,0 , 0, 255); 
        rectMode(CENTER);
        rect(3*ROIWidth+centerOfFoundTemplate.x, centerOfFoundTemplate.y, this.templateROICVMat.cols(), this.templateROICVMat.rows());
        popMatrix();
      }

      this.centerOfFoundTemplateNormalizedInSketch =  normalizePointsFromMainSketchROItoMainSketchWindow(this.centerOfFoundTemplate);
      //end of analysis, if we found something...
      if ( this.centerOfFoundTemplateNormalizedInSketch != null)
      {
        //here we interact with the main sketch
        //updateRotationsVelocity((int) centerOfFoundTemplateNormalizedInSketch.x, (int) centerOfFoundTemplateNormalizedInSketch.y);
        //updateRotationsVelocity((int) centerOfFoundTemplateNormalizedInSketch.x, (int) centerOfFoundTemplateNormalizedInSketch.y);
        displayHere = this.centerOfFoundTemplateNormalizedInSketch;
      }
    }
  }

  //NORMALIZATION IN PRIMARY SKETCH SKETCH COORDINATES
  PVector normalizePointsFromMainSketchROItoMainSketchWindow(PVector toNormalize)
  {
    if (null == toNormalize) return null;


    PVector normalized;
    float normalizedX = map(toNormalize.x, 0, ROIWidth, 0, mainSketch.width);
    float normalizedY = map(toNormalize.y, 0, ROIHeight, 0, mainSketch.height);
    normalized = new PVector(normalizedX, normalizedY);
    return normalized;
  }

  //THIS RETURNS THE ONE WITH THE BEST CROSS-CORRELATION (TEMPLATE MATCHING)
  //WITH THE GIVEN REGISTERED TEMPLATE CHECKED IN THE WHOLE IMAGE
  //IF THE MATCH VALUE IS < MIN TEMPLATE MATCH VALUE NULL IS RETURNED
  PVector findBestTemplateWholeImage( )
  {
    PVector bestMatch = null;
    PImage camImageCopy = imgROImainSketchFromCam.copy();
    float roiTemplateWidth = this.templateROICVMat.cols();
    float roiTemplateHeight = this.templateROICVMat.rows();
    int matchMethod=Imgproc.TM_CCOEFF;

    OpenCV cvTemp = new OpenCV(this, camImageCopy.width, camImageCopy.height);
    camImageCopy.loadPixels();
    cvTemp.loadImage(camImageCopy);
    cvTemp.useColor();
    Mat camImageAsMat = cvTemp.matBGRA;
    Mat outputImage=new Mat(); 
    Imgproc.matchTemplate(camImageAsMat, this.templateROICVMat, outputImage, matchMethod);
    MinMaxLocResult mmr = Core.minMaxLoc(outputImage);
    
    int maxxloc = (int)mmr.maxLoc.x;
    int maxyloc = (int)mmr.maxLoc.y;
    
    float maxabsval = brightness( camImageCopy.pixels[maxxloc + maxyloc * camImageCopy.width]) ;
    
    if(maxabsval >= MIN_TEMPLATE_MATCH_ABSVALUE) 
      bestMatch = new PVector((float)(mmr.maxLoc.x+ roiTemplateWidth * .5), (float)(mmr.maxLoc.y+ roiTemplateHeight * .5));
    
    
    
    
    return bestMatch;
  }




  //GIVEN THE INTERESTING POINTS,
  //THIS RETURNS THE ONE WITH THE BEST CROSS-CORRELATION (TEMPLATE MATCHING)
  //WITH THE GIVEN REGISTERED TEMPLATE
  //IF THE MATCH VALUE IS < MIN TEMPLATE MATCH VALUE NULL IS RETURNED
  PVector findBestTemplateMatchFromPoints(ArrayList<PVector> points)
  {
    if (null == points)
      return null;

    //for every detected point
    //we extract a portion of the original cam image, containing that point (of double the size of the roi template)
    //we use template match between that portion and the registered template
    //and we take the max value of the match
    //the point whose portion has the biggest match with the registered template is the point we return
    PImage camImageCopy = imgROImainSketchFromCam.copy();
    float roiTemplateWidth = this.templateROICVMat.cols();
    float roiTemplateHeight = this.templateROICVMat.rows();
    int matchMethod=Imgproc.TM_CCOEFF;
    int idxBestMatch = -1;
    float maxValMatch = 0;

    for (int i = 0; i< points.size(); i++)
    {
      PVector point = points.get(i);
      PVector ulPortion = new PVector( point.x -  .5*roiTemplateWidth, point.y -.5* roiTemplateHeight  ); 
      PVector drPortion = new PVector( point.x + roiTemplateWidth*.5, point.y + roiTemplateHeight *.5 );
      if (ulPortion.x < 0 ) ulPortion.x = 0;
      if (ulPortion.y < 0 ) ulPortion.y = 0;
      if (drPortion.x >= camImageCopy.width) drPortion.x = camImageCopy.width -1;
      if (drPortion.y >= camImageCopy.height) drPortion.y = camImageCopy.height -1;

      //this is the portion of the original image, centered in the detected point in the rgb/hue space
      PImage originalCamImagePortion = camImageCopy.get((int)ulPortion.x, (int)ulPortion.y, (int)(drPortion.x - ulPortion.x), (int) (drPortion.y -ulPortion.y));
      originalCamImagePortion.updatePixels();
      OpenCV cvTemp = new OpenCV(this, originalCamImagePortion.width, originalCamImagePortion.height);
      cvTemp.useColor();
      cvTemp.loadImage(originalCamImagePortion);
      Mat originalCamImagePortionAsCvMat = cvTemp.matBGRA;
      Mat outputImage=new Mat(); 
      Imgproc.matchTemplate(originalCamImagePortionAsCvMat, this.templateROICVMat, outputImage, matchMethod);
      MinMaxLocResult mmr = Core.minMaxLoc(outputImage);
      int locx = (int)mmr.maxLoc.x;
      int locy = (int)mmr.maxLoc.y;
      color maxcol = originalCamImagePortion.pixels[locx + locy * originalCamImagePortion.width];
      float absoluteval = brightness(maxcol);
      float maxVal = absoluteval;//mmr.maxVal;
      if (maxVal > maxValMatch)
      {
        maxValMatch = maxVal;
        idxBestMatch =  i;
      }
    }
    
    if(idxBestMatch != -1 && maxValMatch >= MIN_TEMPLATE_MATCH_ABSVALUE)
    {
      return points.get(idxBestMatch); 
    }
     return null;
 
  }


  //THIS RETURNS ALL THE POINTS WITH THE RGB (or HUE) in the RANGE OF THE REGISTERED RANGE
  ArrayList<PVector> detectInterestingPointsInColorSpace()
  {
    ArrayList<PVector> interestingPoints = new ArrayList<PVector>();
    //work only in camera frame in ROIupperleft e ROIdownright boundaries
    if (cam.available()) {
      //read from camera
      cam.read();
      PImage imgtT = cam.get();
      //extract the ROI from camera
      this.imgROImainSketchFromCam = imgtT.get((int)ROIupperleft.x, (int)ROIupperleft.y, (int)ROIWidth, (int)ROIHeight); 

      //IMAGE PROCESSING
      //0 ELIMINATE ALL PIXELS OUTSIDE THE MIN AND MAX RGB (OF EVERY CHANNEL) FROM THE TEMPLATE ROI
      PImage temp0 = imgROImainSketchFromCam.copy();
      temp0.loadPixels();
      ;
      for (int i = 0; i< temp0.pixels.length; i++)
      {
        if (green(temp0.pixels[i]) < greenMinMaxFromTemplateROI.x ||  green(temp0.pixels[i]) > greenMinMaxFromTemplateROI.y 
          || red(temp0.pixels[i]) < redMinMaxFromTemplateROI.x ||  red(temp0.pixels[i]) > redMinMaxFromTemplateROI.y
          || blue(temp0.pixels[i]) < blueMinMaxFromTemplateROI.x ||  blue(temp0.pixels[i]) > blueMinMaxFromTemplateROI.y
          ) 
          temp0.pixels[i] = color(#000000);
      }
      temp0.updatePixels();
      this.imgROImainSketchFromCamThresholded = temp0.copy();

      //LEAVE ALL THE PIXEL EXACTLY (MORE OR LESS) MATCHING THE CENTER OF THE ROI IN THE COLOR SPACE
      PImage temp1 = temp0.copy();
      temp1.loadPixels();
      for (int i = 0; i< temp1.pixels.length; i++)
      {
        if ( abs(red(temp1.pixels[i])-rValCenterOfTemplateRoi) > 10 || abs(green(temp1.pixels[i])-gValCenterOfTemplateRoi) > 10 || abs(blue(temp1.pixels[i])-bValCenterOfTemplateRoi) > 10) 
          temp1.pixels[i] = color(#000000);
        else temp1.pixels[i] = color(#ffffff);
      } 
      temp1.updatePixels();
      this.imgROImainSketchFromCamThresholded2 = temp1.copy();

      //MORPHOLOGICAL OPERATIONS
      PImage temp2 = temp1.copy();
      opencv2.loadImage(temp2);
      //morphological operators
      opencv2.setGray(opencv2.getR().clone());
      opencv2.blur(3);
      opencv2.dilate(); 
      opencv2.erode(); 
      this.imgROImainSketchFromCamMorphological = opencv2.getSnapshot();

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

  void registraROIMainSketchCamera()
  {
    ROIupperleft = firstClickMousePosition.copy();
    ROIdownright = new PVector(mouseX, mouseY); 
    ROIWidth = ROIdownright.x - ROIupperleft.x;
    ROIHeight = ROIdownright.y - ROIupperleft.y;
  }

  void registraROITemplate()
  {

    PImage roiImage = imgROImainSketchFromCam.get((int)firstClickMousePosition.x, (int)firstClickMousePosition.y, 
      mouseX-(int)firstClickMousePosition.x, mouseY-(int)firstClickMousePosition.y);

    OpenCV opencvT = new OpenCV(this, roiImage.width, roiImage.height);
    opencvT.loadImage(roiImage);
    opencvT.useColor();
    this.templateROICVMat = opencvT.matBGRA;

    //the min and max points in the roi, are used to calculate
    //the range of the points to eliminate
    //and the center of the roi is used to detect the best candidate for template matching
    OpenCV opencvT2 = new OpenCV(this, roiImage.width, roiImage.height);
    opencvT2.loadImage( roiImage.copy());
    //opencvT2.useColor();
    //for red we get the min and max values in the roi
   // opencvT2.setGray(opencvT2.getR()); 
    PVector maxLoc = opencvT2.max();
    PVector minLoc = opencvT2.min();
    redMinMaxFromTemplateROI = new PVector( red( roiImage.get((int)minLoc.x, (int)minLoc.y) ), red(roiImage.get((int)maxLoc.x, (int)maxLoc.y) ));
    //again for the green 
    opencvT2.useColor();
    opencvT2.setGray(opencvT2.getG()); 
    maxLoc = opencvT2.max();
    minLoc = opencvT2.min();
    greenMinMaxFromTemplateROI = new PVector( green(roiImage.get((int)minLoc.x, (int)minLoc.y)), green(roiImage.get((int)maxLoc.x, (int)maxLoc.y) ));
    //and blue
    opencvT2.useColor();
    opencvT2.setGray(opencvT2.getB()); 
    maxLoc = opencvT2.max();
    minLoc = opencvT2.min();
    blueMinMaxFromTemplateROI = new PVector( blue(roiImage.get((int)minLoc.x, (int)minLoc.y)), blue(roiImage.get((int)maxLoc.x, (int)maxLoc.y) ));
    
    println(">>>THE MIN-MAX VALUES , IN THE TEMPLATE ROI, FOR THE RGB CHANNELS ARE: "+redMinMaxFromTemplateROI.x+","+redMinMaxFromTemplateROI.y+"//"
      +greenMinMaxFromTemplateROI.x+","+greenMinMaxFromTemplateROI.y+"//"+blueMinMaxFromTemplateROI.x+","+blueMinMaxFromTemplateROI.y);
    
    //now we need the rgb value for the center of the template (used to detected the candidates)
    
    roiImage.loadPixels();
    color centerColor = roiImage.pixels[ (int)(roiImage.width * .5) + (int)(roiImage.height * .5) * roiImage.width ];
    rValCenterOfTemplateRoi = red(centerColor);
    bValCenterOfTemplateRoi = blue(centerColor);
    gValCenterOfTemplateRoi = green(centerColor);
  
    println(">>>THE RGB , TAKEN FROM THE TEMPLATE ROI CENTER, FOR POINT CANDIDATES DETECTION IS: "+
      rValCenterOfTemplateRoi+"(+-10)//"+gValCenterOfTemplateRoi+"(+-10)//"+bValCenterOfTemplateRoi+"(+-10)//");

  }

  void mousePressed()
  {
    if (SKETCH_MODE == 0 || SKETCH_MODE == 1)
    { 
      if (firstClickMousePosition == null)
        firstClickMousePosition = new PVector(mouseX, mouseY);
    }
  }


  void mouseReleased()
  {
    if (SKETCH_MODE == 0)
    {
      registraROIMainSketchCamera();
      firstClickMousePosition = null; 
      println(">>>REGISTERED ROI FOR PRIMARY SKETCH IN CAMERA");
    } else if (SKETCH_MODE == 1)
    {
      registraROITemplate();
      firstClickMousePosition = null; 
      println(">>>REGISTERED ROI FOR TEMPLATE");
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
