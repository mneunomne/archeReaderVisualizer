// archeReaderVisualizer - 21.08.2023
import java.util.*;
import processing.serial.*;
import processing.video.*;
import netP5.*;
import oscP5.*;
import codeanticode.syphon.*;

SyphonClient client;

Capture video;

int LOCAL_PORT = 12001;
OscP5 oscP5;

int w, h;

int currentX = 0;
int currentY = 0;

PImage img;

int cropped_size = 200;

void setup () {
  size(400, 800, P2D);
  oscP5 = new OscP5(this, LOCAL_PORT);
  initCamera();
  // client = new SyphonClient(this);
}

void initCamera() {
  String[] cameras = Capture.list();
  int cameraIndex = Arrays.asList(cameras).indexOf("OBS Virtual Camera");
  if (cameras.length == 0) {
    println("[Camera] There are no cameras available for capture.");
    exit();
  } else {
    println("[Camera] Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    if (cameraIndex == -1) {
      println("[Camera] No OBS Virtual Camera camera found, using default one instead");
      video = new Capture(this, cameras[0], 30);
    } else {
      video = new Capture(this, cameras[0], 30);
    }
    video.start();
  }
  w = video.width;
  h = video.height;
  println("[Camera] video size", w, h);
  background(0);
}  

void draw () {
  tint(255, 0,0, 100);
  
  // crop image to central 200, 200 pixels
  PImage cropped = getCroppedImage();
  image(video, currentX, currentY, 100, 100);
}

PImage getCroppedImage() {
  int x = w/2 - cropped_size/2;
  int y = h/2 - cropped_size/2;
  return video.get(x, y, cropped_size, cropped_size);
}

void receiveImage(float perc_x, float perc_y) {
  int x = int(perc_x * (width - 100));
  int y = int(perc_y * (height - 100));
  currentX = x;
  currentY = y;
  // background(0, 255, 0);
  println("received image", x, y);
  if (video.available()) {
    video.read();
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* get and print the address pattern and the typetag of the received OscMessage */
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();
  String pattern = theOscMessage.addrPattern();
  println("pattern", pattern);
  if (pattern.contains("/live_feed")) {
     float perc_x = theOscMessage.get(0).floatValue();
     float perc_y = theOscMessage.get(1).floatValue();
     receiveImage(perc_x, perc_y);
  }
}