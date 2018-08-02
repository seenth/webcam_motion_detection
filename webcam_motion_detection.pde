import processing.video.*;
ArrayList<Particle> particles; 

Capture video;
PImage prev;

float threshold = 50;

//used with lerp
float motionX = 0;
float motionY = 0;

//smooth the motion
float lerpX = 0;
float lerpY = 0;

void setup() {
  //camera size should match sketch size
  size(640, 360);
  //print list of available cameras to console
  String[] cameras = Capture.list();
  printArray(cameras);
  //capture(this, w, h, fps)
  video = new Capture(this, cameras[3]);
  video.start();
  prev = createImage(640, 360, RGB); //make blank image
  
  particles = new ArrayList<Particle>();

}

void captureEvent(Capture video) {
  prev.copy(video, 0,0,video.width,video.height,0,0,prev.width,prev.height);
  prev.updatePixels();
  //read from camera, create new image
  video.read();
  
}

void draw() {
  background(0);
  video.loadPixels();
  prev.loadPixels();
  image(video,0,0);
  //closest color
  
  int count = 0;
  float avgX = 0;
  float avgY = 0;
  
  loadPixels();
  //computer vision algorithm to look at every pixel
  for (int x = 0; x < video.width; x++) {
    for (int y = 0; y < video.height; y++) {
      int loc = x + y * video.width;
      //find current color of mouse x/y
      color currentColor = video.pixels[loc]; 
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      color prevColor = prev.pixels[loc]; 
      float r2 = red(prevColor);
      float g2 = green(prevColor);
      float b2 = blue(prevColor);
      
      //euclidean distance
      float d = distSq(r1,g1,b1,r2,g2,b2);
      
      if (d > threshold * threshold) {
       //stroke(255);
       //strokeWeight(1);
       //point(x,y);
       avgX += x;
       avgY += y;
       count++;
      //pixels[loc] = color(255);
    } else {
      //pixels[loc] = color(0);
    }
   }
  }
   updatePixels(); 
   
    if (count > 200) {
      motionX = avgX / count;
      motionY = avgY / count;
    }
      lerpX = lerp(lerpX, motionX, 0.1);
      lerpY = lerp(lerpY, motionY, 0.1);
      //fill(255,0,255);
      //strokeWeight(2);
      //stroke(0);
      //ellipse(lerpX, lerpY, 16,16);
      particles.add(new Particle(new PVector(lerpX, lerpY)));
      for (int i = particles.size()-1; i >=0 ; i--) {
        Particle p = particles.get(i);
        p.update();
        p.display();
        if (p.isDead()) {
        particles.remove(i);
      }
      }
      //saveFrame("output/oct5_####.png");

}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
 float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1);
 return d;
}