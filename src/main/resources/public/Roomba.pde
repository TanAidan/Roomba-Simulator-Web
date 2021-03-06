class Roomba {
  private float definition; 
  private float scaleFactor;
  private int light = 50;
  private int incRed = -4;
  private float drawingRadius;

  private float x = 450;
  private float y = 450;
  private String id;
  private float radius = 40;
  private boolean bump;
  private float angularVelocity;
  private PVector linearVelocity = new PVector(0, 0);
  private float preSpeed;
  private float drivingRadius;
  private float angle = 0;
  final float CLOCKWISE= 0xFFFF;
  final float COUNTER_CLOCKWISE = 0x7FFF;

  public Roomba(String id, float x, float y, float radius, float angle) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.angle = angle;

    definition = 200/radius + 1;
    drawingRadius = definition * radius;
    scaleFactor = 1/definition;
  }
  
  public void update() {
    checkCollision();
    //drive(0, 0);
    if (!bump)
      drive(preSpeed/55.9, drivingRadius);


    while(angle > 2*PI)
      angle-=2*PI;
      
    while(angle < -2*PI)
      angle+=2*PI;

    stroke(0);
    strokeWeight(1.5);
    fill(255);
    rectMode(CORNER);
    rect(15, 5, 480, 20);
    fill(255, 0, 0);
    text("Left Sensor: " + (int) getUltrasonicDistance(LEFT), 20, 20);
    text("Center Sensor: " + (int) getUltrasonicDistance(CENTER), 145, 20);
    text("Right Sensor: " + (int) getUltrasonicDistance(RIGHT), 275, 20); 
    
  }

  public float getRadius() {
    return radius;
  }

  public void driveDirect(int left, int right) {
    if (left > 500)
      left = 500;
    if (left < -500)
      left = -500;
    if (right > 500)
      right = 500;
    if (left < -500)
      left = -500;
    
    preSpeed = ((float) left  + (float) right) / ((width + height)/2 / (GRID_SIZE * 2.0f));
    float ratio = ((float) left  / (float) right);
    drivingRadius = ((ratio+1) * (0.74*radius))/(ratio - 1);
    
    
    if(left == -right) {
      preSpeed = abs(left);
      
      if(left > right) 
        drivingRadius = CLOCKWISE;
      else
        drivingRadius = COUNTER_CLOCKWISE;
    }
  }

  private void drive(float speed, float r) {

    float a = 0;  
    float y1 = 0;
    float x1 = 0;
    
    if(r != CLOCKWISE && r != COUNTER_CLOCKWISE) {
    if(r == 0)
    {
  	  a==0;
    }
    else
    {
   	 a = (speed/r) * 9.56;  
    } 
    println(r + " " +a + " " +speed);
    y1 = (float) (Math.cos(angle) * speed);
    x1 = (float) (Math.sin(angle) * speed);
    }
    
    if(r == CLOCKWISE)
      a = speed/50;
    else if (r == COUNTER_CLOCKWISE)
      a = -speed/50;
    
    
    setLinearVelocity(new PVector(x1, y1));
    setAngularVelocity(a);
    angle += angularVelocity;
    x += linearVelocity.x;
    y += linearVelocity.y;
    //println("xSpeed: " + linearVelocity.x);
    //println("ySpeed: " + linearVelocity.y);
    //println("a: " + a);
    //println("dRadius: " + drivingRadius);
  }

  private int drawRedDot() {
    light += incRed;
    if (light <= 0 || light >= 255)
      incRed = -incRed;
    return light;
  }


  public void display() {

    pushMatrix();
    translate(x, y);
    scale(scaleFactor);
    rotate(angle);
    fill(0);
    stroke(0);
    strokeWeight(2);
    ellipse(0, 0, drawingRadius * 2, drawingRadius * 2);
    fill(100);
    arc(0, 0, drawingRadius * 2, drawingRadius * 2, 0, 2 * PI);
    fill(0);
    arc(0f, 0f, drawingRadius * 2.15f, drawingRadius * 2.15f, PI * 1.0f, 2.0f * PI);
    fill(169, 217, 109);
    arc(0f, 0f, drawingRadius * 1.75f, drawingRadius * 1.75f, 0f, 2f * PI);
    fill(255, 255, 184);
    arc(0, 0, drawingRadius, drawingRadius, 0, 2 * PI);
    fill(20);
    arc(0, 0, drawingRadius * .74f, drawingRadius * .75f, 0, 2 * PI);
    fill(230, 242, 244);
    arc(0, 0, drawingRadius / 2, drawingRadius / 2, 0, 2 * PI);
    fill(100);
    arc(0, 0 + drawingRadius * .875f, drawingRadius / 3, drawingRadius / 3, 0, 2 * PI);
    fill(100);
    arc(0, 0 + drawingRadius * .875f, drawingRadius / 4, drawingRadius / 4, 0, 2 * PI);
    fill(100);
    arc(0, 0 - drawingRadius, drawingRadius / 4f, drawingRadius / 4, 0, 2 * PI);
    fill(255, drawRedDot(), light);
    noStroke();
    ellipse(1, 1, 3 * drawingRadius/50, 3 * drawingRadius/50);

    float uWidth = 0.3 * drawingRadius;

    translate(uWidth/2, -1.06 * drawingRadius);
    rotate(PI);
    drawUltrasonic(uWidth);

    translate(uWidth/2, -1.06 * drawingRadius - uWidth/2);
    translate(-0.95 * drawingRadius, 0);
    rotate(PI/2);
    drawUltrasonic(uWidth);

    translate(uWidth, -1.9 * drawingRadius);
    rotate(PI);
    drawUltrasonic(uWidth);

    popMatrix();
  }

  public float getUltrasonicDistance(int sensorPosition) {
    float ySpeed = 1;
    float xSpeed = 1;
    float beamX = x;
    float beamY = y;
    float angleCalc = angle;

    if (sensorPosition == CENTER) {
      ySpeed = tan(angleCalc - PI/2);
      
      if (abs(angleCalc) > PI) {
        ySpeed = -ySpeed;
        xSpeed = -xSpeed;
      }
      if (angleCalc < 0) {
        ySpeed = -ySpeed;
        xSpeed = -xSpeed;
      }
      if (angleCalc == 0) {
        ySpeed = -1;
        xSpeed = 0;
      }
      if (abs(angleCalc) == PI) {
        ySpeed = 1;
        xSpeed = 0;
      }
    }

    if (sensorPosition == RIGHT) {
      ySpeed = tan(angleCalc);
    }

    if (sensorPosition == LEFT) {
      ySpeed = tan(angleCalc);
      ySpeed = -ySpeed;
      xSpeed = -xSpeed;
      
      if (angleCalc == 0) {
        ySpeed = 0;
        xSpeed = -1;
      }
    }
    
    if (sensorPosition == LEFT || sensorPosition == RIGHT) {
      if (abs(angleCalc) > PI/2) {
        ySpeed = -ySpeed;
        xSpeed = -xSpeed;
      }

      if (abs(angleCalc) > 1.5 * PI) {
        ySpeed = -ySpeed;
        xSpeed = -xSpeed;
      }
    }
    
    while (abs(ySpeed) > 1) {
      ySpeed *= 0.5;
      xSpeed *= 0.5;
    }

    //if(abs(angleCalc) == PI) {
    //ySpeed = -ySpeed;
    //xSpeed = -xSpeed; 
    //}
    
    
    Entity testEntity = new Entity();
    for (int i = 0; i < width + height; i++) {
      if (testEntity.checkCollision(beamX, beamY) != null|| beamX >= width || beamX <= 0 || beamY <= 0 || beamY >= height) {
        return i * sqrt(sq(xSpeed) + sq(ySpeed)) - 1.1 * radius;
      }

      beamX += xSpeed;
      beamY += ySpeed;
      //fill(0, 255, 0);
      //ellipse(beamX, beamY, 1, 1);
    }

    return -1;
  }

  private void drawUltrasonic(float uWidth) {
    fill(#348DC2);
    rect(0, 0, uWidth, 0.044 * uWidth);
    fill(#D7DED9);
    rect(0.133 * uWidth, 0.044 * uWidth, 0.222 * uWidth, 0.222 * uWidth);
    rect(0.644 * uWidth, 0.044 * uWidth, 0.222 * uWidth, 0.222 * uWidth);
    fill(#000000);
    rect(0.111 * uWidth, -0.011 * uWidth, 0.088 * uWidth, 0.011 * uWidth);
    rect(0.416 * uWidth, -0.011 * uWidth, 0.066 * uWidth, 0.011 * uWidth);
    rect(0.744 * uWidth, -0.011 * uWidth, 0.2 * uWidth, 0.011 * uWidth); 
    fill(#ACB19A);
    rect(0.433 * uWidth, 0.044 * uWidth, 0.133 * uWidth, 0.022 * uWidth);
    rect(0.244 * uWidth, -0.011 * uWidth, 0.022 * uWidth, 0.011 * uWidth);
    rect(0.316 * uWidth, -0.011 * uWidth, 0.066 * uWidth, 0.011 * uWidth);
    rect(0.616 * uWidth, -0.011 * uWidth, 0.066 * uWidth, 0.011 * uWidth);
  }


  public boolean isBump() {
    return bump;
  }

  public void setBump(boolean bump) {
    this.bump = bump;
  }

  public void setAngularVelocity(float newVelocity) {
    angularVelocity = newVelocity/6.0;
  }

  public void setLinearVelocity(PVector newVelocity) {
    linearVelocity = new PVector(newVelocity.x * 1.6, newVelocity.y * -1.6);
  }
  public void checkCollision() {
    float wideRadius = 1.1 * radius;
    Entity testEntity = new Entity();
    if (testEntity.checkCollision(x + wideRadius, y) != null || testEntity.checkCollision(x - wideRadius, y) != null  || testEntity.checkCollision(x, y + wideRadius)  != null || testEntity.checkCollision(x, y - wideRadius)  != null /* || x + wideRadius >= width || x - wideRadius <= 0  || y + wideRadius >= height */ || y - wideRadius <= 0 ) {
      setBump(true);
      //if(testEntity.getCollided().getId().equals("endzone")) {
      //}
    } else {
      setBump(false);
    }
  }
}