/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/10475*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */

import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;


Minim minim;
AudioInput in;
float spectrumScale = 4;

//Containing rectangle verteices for Perlin Noise clockwise named
int v0_x, v1_x;

//Maximum Number of Particles in the System, Counter for keeping track of 
//the number of Particles generated Counter for keeping track of the 
//number of dead particles
int MAX_PARTICLES = 1000, COUNTER = 0, DEAD_COUNT = 0;
//Particle Array
Particle[] points;
//Dead particles index ArrayList
ArrayList<Integer> deadPoints;
int elapsedFrames = 0;

// PRECISION FOR BOTH CHANNELS
//Precision value >= 1.5 is highly imposible to feel anything
//For R Channel it will ignore values between precisionR and -precisionR
//And the same for L Channel.
float precisionL = 0.005, precisionR = 0.005;

// Lifetime for every Particle in the System. Old Initial: 250
int lifeTime = 700;

//Particles Transparency where 0 is fully transparent and 255 is fully opaque
int ParticleAlpha = 30;

//Particles Speed reducing Factor from 1.1 to whatever to go from more speed to less speed.
float ParSpeedRedFactor = 1.3;

//Mode:
boolean linesMode = false;
//justDeactivated acts as a white rectangle restarter trigger
boolean justDeactivated = false;


void setup()
{
  size(displayWidth, displayHeight, P3D);
  //size(1200, 650, P3D);
  frame.setTitle(""); 
  //value to the Perlin Noise container
  v0_x = 100; v1_x = width-100;
  background(255);
  stroke(255);
  //Array of Particles
  points = new Particle[MAX_PARTICLES];
  //Init Dead Particle Array
  deadPoints = new ArrayList<Integer>();
  //we create a Minim object
  minim = new Minim(this);
  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn();
}

void draw()
{
    if (linesMode || justDeactivated) {
      fill(255, 255);
      rect(0,0, v0_x+5, height); //we add a 5 margin
      fill(255, 255);
      rect(v1_x,0, width-v0_x-5, height); //we add a 5 margin
      justDeactivated = false;
    }
    float leftValue, rightValue;
    for(int i = 0; i < in.bufferSize() - 1; i++){
      rightValue = in.right.get(i);
      if ((rightValue*50 > precisionR) || rightValue*50 < (-1)*precisionR){
        if (COUNTER < MAX_PARTICLES) {
          PVector pos = new PVector();
          pos.x = v1_x-70;
          pos.y = (height/2)+random(-(height-50),(height-50));
          
          PVector vel = new PVector();
          vel.x = (0);
          vel.y = (0);
         
          Particle part = new Particle(pos, vel, lifeTime);
          points[COUNTER] = part;
          ++COUNTER;
        }
        //Reborn another particle
        if (!deadPoints.isEmpty()) {
          PVector pos = new PVector();
          pos.x = v1_x-70;
          pos.y = (height/2)+random(-(height-50),(height-50));
          
          PVector vel = new PVector();
          vel.x = (0);
          vel.y = (0);
         
          Particle part = new Particle(pos, vel, lifeTime);
          //we put this particle in the position where we had the first dead particle thus repacing it
          points[(int)deadPoints.get(0)] = part;
          ++COUNTER;
          deadPoints.remove(0); //remove index 0
          --DEAD_COUNT;
        }
      }
      leftValue = in.left.get(i);
      if ((leftValue*50 > precisionL) || (leftValue*50 < (-1)*precisionL)){
        if (COUNTER < MAX_PARTICLES) {
          PVector pos = new PVector();
          pos.x = v0_x+70;
          pos.y = (height/2)+random(-(height-50),(height-50));
          
          PVector vel = new PVector();
          vel.x = (0);
          vel.y = (0);
         
          Particle part = new Particle(pos, vel, lifeTime);
          points[COUNTER] = part;
          ++COUNTER;
        }
        //Reborn another particle
        if (!deadPoints.isEmpty()) {
          PVector pos = new PVector();
          pos.x = v0_x+70;
          pos.y = (height/2)+random(-(height-50),(height-50));
          
          PVector vel = new PVector();
          vel.x = (0);
          vel.y = (0);
         
          Particle part = new Particle(pos, vel, lifeTime);
          //we put this particle in the position where we had the first dead particle thus repacing it
          points[(int)deadPoints.get(0)] = part;
          ++COUNTER;
          deadPoints.remove(0); //remove index 0
          --DEAD_COUNT;
        }
      }
      if (linesMode) {
        stroke(0);
        line((v0_x/2) + in.left.get(i)*50, i, (v0_x/2) + in.left.get(i+1)*50, i+1);
        line(width - (v0_x/2) + in.right.get(i)*50, i, width - (v0_x/2) + in.right.get(i+1)*50, i+1);
      }
    }
    
    //we look through the number of particles that we have created until this point, not up to the MAX
    //otherwise will crash
    for(int i = 0; i < COUNTER; ++i){
      Particle localPoint = (Particle) points[i];
      if(localPoint.isDead == true){
        deadPoints.add((Integer)i); //Added to the list
        ++DEAD_COUNT;
      }
      localPoint.update();
      localPoint.draw();
      COUNTER -= DEAD_COUNT; //update counter due to the casualties
    }
    elapsedFrames++;
}

//Reset the particles canvas and variables
void resetCanvas(){
    //reset the noise particles zone
    if (linesMode){
      fill(255, 255);
      rect(95, 0, width-95, height);
    }
    else {
      fill(255, 255);
      rect(0, 0, width, height);
    }
    //reset the variables
    COUNTER = 0; DEAD_COUNT = 0; elapsedFrames = 0;
    //empty array and arraylist
    points = new Particle[MAX_PARTICLES];
    deadPoints = new ArrayList<Integer>();
}

void keyPressed()
{
  switch (key) {
    
    case 'l':
      if (linesMode) {
        linesMode = false;
        println("PERLIN WITH SPECTRUM MODE DEACTIVATED");
        //we activate justDeactivated
        justDeactivated = true;
      }
      else {
        linesMode = true;
        println("PERLIN WITH SPECTRUM MODE ACTIVATED");
      }
      break;
      
    case 'r': //RESET
      resetCanvas();
      println("RESET DONE");
      break;
      
    default:
      break;
      
  };
  
}
