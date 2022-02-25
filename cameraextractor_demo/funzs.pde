color[][] colors = new color[][]{ 
  new color[]{#f72585, #b5179e, #7209b7, #560bad, #480ca8, #3a0ca3, #3f37c9, #4361ee, #4895ef, #4cc9f0}, 
  new color[]{#ffbe0b, #fb5607, #ff006e, #8338ec, #3a86ff, #8ecae6, #219ebc, #126782, #023047}, 
  new color[]{#ffbe0b, #fb5607, #ff006e, #7400b8, #6930c3, #5e60ce, #5390d9, #4ea8de, #48bfe3, #56cfe1, #64dfdf, #72efdd, #80ffdb}, 
  new color[]{#ffbe0b, #fb5607, #ff006e, #8ecae6, #219ebc, #126782, #023047, #ffb703, #fd9e02, #fb8500}, 
  new color[]{#ffbe0b, #fb5607, #ff006e, #f94144, #f3722c, #f8961e, #f9c74f, #90be6d, #43aa8b}, 
  new color[]{#590d22, #800f2f, #a4133c, #c9184a, #ff4d6d, #ff758f, #ff8fa3, #ffb3c1, #ffccd5, #fff0f3}, 
  new color[]{#ff6d00, #ff7900, #ff8500, #ff9100, #ff9e00, #240046, #3c096c, #5a189a, #7b2cbf, #9d4edd}, 
  new color[]{#ff6d00, #b7094c, #a01a58, #892b64, #723c70, #5c4d7d, #455e89, #2e6f95, #1780a1, #0091ad}, 
  new color[]{#ff6d00, #b7094c, #a01a58, #892b64, #723c70, #ff595e, #ffca3a, #8ac926, #1982c4, #6a4c93}, 
  new color[]{#00111c, #001523, #001a2c, #002137, #00253e, #002945, #002e4e, #003356, #003a61, #00406c}, 
  new color[]{#ff6d00, #ff8500, #ff9100, #ff9e00, #3a86ff, #0096c7, #0077b6, #023e8a, #03045e}
};



class Element
{
  float _width, _height;
  PVector center;
  PVector upperCorner;
  color fillColor, strokeColor;
  float strokeAlpha, fillAlpha; 
  int idxRow, idxCol;
  int strokeWeight;
  float rotationAngle = 0;
  float angleVelocity = 0;
  float angleFriction;

  public Element(int idxRow, int idxCol, PVector upperCorner, PVector center, float _width, float _height, color strokeColor, float strokeAlpha, 
    int strokeWeight, color fillColor, float fillAlpha, float rotationAngle, float angleVelocity, float angleFriction)
  {
    this.idxRow = idxRow;
    this.idxCol = idxCol;
    this.center = center; 
    this._width = _width; 
    this._height = _height;
    this.upperCorner = upperCorner;
    this.strokeColor = strokeColor;
    this.fillColor = fillColor;
    this.strokeAlpha = strokeAlpha;
    this.fillAlpha = fillAlpha;
    this.rotationAngle = rotationAngle;
    this.strokeWeight = strokeWeight;
    this.angleVelocity = angleVelocity;
    this.angleFriction = angleFriction;
  }



  void _draw()
  {
    strokeWeight(1.0); 
    rectMode(CENTER);
    //alpha according to rotation velocity
    float alpha = map(this.angleVelocity, 0, 0.3, 0, 255);
    noFill();
    if (alpha > 3)
    {
      //fill(this.fillColor, alpha);
      //stroke(this.fillColor, 255);
      stroke(this.strokeColor, 100);
    } else
    {

      //noStroke();
      stroke(this.strokeColor, alpha);
    }


    if (alpha > 3)
    {
      int mi = ceil(map(this.angleVelocity, 0, 0.3, 0, 5));
      float miwidth = _width/(float)mi;
      float miheight = _height/(float)mi;

      for (int i = 0; i< mi; i++)
      {
        for (int j = 0; j< mi; j++)
        {
          pushMatrix();
          translate(this.upperCorner.x+ j*miwidth + miwidth/2.0, this.upperCorner.y+ i*miheight +miheight/2.0);
          rotate(this.rotationAngle);
          //rect(0, 0, miwidth, miheight);
          line(0, 0, this.center.x-this.upperCorner.x, this.center.y-this.upperCorner.y);
          popMatrix();
        }
      }
    } else
    {
      pushMatrix();
      translate(this.center.x, this.center.y);
      rotate(this.rotationAngle);
      line(0, 0, this.center.x-this.upperCorner.x, this.center.y-this.upperCorner.y);
      //rect(0, 0, this._width, this._height);
      popMatrix();
    }
  }

  void updateRotationParameters()
  {
    this.rotationAngle += (this.angleVelocity); 
    this.angleVelocity -= (this.angleFriction);
    this.angleVelocity = max(this.angleVelocity, 0.0);
  }
} 


public void drawAllElements()
{
  for (int i = 0; i< elements.length; i++)
  {
    for (int j = 0; j< elements[i].length; j++)
    {
      elements[i][j]._draw();
    }
  }
}

public void initElements()
{
  elements = new Element[NUM_ROWS][NUM_COLS]; 
  float col_width = width / (float)NUM_COLS;
  float row_height = height / (float)NUM_ROWS;

  for (int i = 0; i < NUM_ROWS; i++)
  {
    for (int j = 0; j< NUM_COLS; j++)
    {
      color colort = colors[0][(j+i) % colors[0].length];
      elements[i][j] = new Element(  i, j, new PVector( j * col_width, i * row_height ), new PVector( j* col_width + .49 * col_width, i * row_height + .49 * row_height ), col_width, row_height, color(#ffffff), 255, 3, colort, 255, 0 
        , 0, 0.001);
    }
  }
}


public void updateRotations()
{ 

  for (int i = 0; i < NUM_ROWS; i++)
  {
    for (int j = 0; j< NUM_COLS; j++)
    {  
      elements[i][j].updateRotationParameters();
    }
  }
}

public void updateRotationsVelocity(int _centerx, int _centery)
{   
  float velocityOfClicked = 0;
  int iClicked = _centery / (width/NUM_COLS);
  int jClicked = _centerx / (width/NUM_ROWS);
  velocityOfClicked = elements[iClicked][jClicked].angleVelocity;

  for (int i = 0; i < NUM_ROWS; i++)
  {
    for (int j = 0; j< NUM_COLS; j++)
    {  
      float distFromMouse = new PVector(_centerx, _centery).sub(elements[i][j].center.copy()).mag();
      //threshold distance on pre-existing velocity on clicked element
      float threshold = map(velocityOfClicked, 0, 0.4, width*0.05, width*0.2);
      if (distFromMouse > threshold)
        continue;
      float newAngleVel = 0.04-map(distFromMouse, 0, 0.5*sqrt(width*width+height*height), 0, 0.0001);
      newAngleVel = max(newAngleVel, 0);
      elements[i][j].angleVelocity += newAngleVel;
    }
  }
}
