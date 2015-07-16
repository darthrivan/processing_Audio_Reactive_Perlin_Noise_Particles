/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/10475*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */

class Particle {
  PVector pos, vel, noiseVec;
  float noiseFloat, lifeTime, age;
  boolean isDead;
   
  public Particle(PVector _pos, PVector _vel, float _lifeTime){
    pos = _pos;
    vel = _vel;
    lifeTime = _lifeTime;
    age = 0;
    isDead = false;
    noiseVec = new PVector();
  }
   
  void update(){
    noiseFloat = noise(pos.x * 0.0025, pos.y * 0.0025, elapsedFrames * 0.001);
    noiseVec.x = cos(((noiseFloat -0.3) * TWO_PI) * 10);
    noiseVec.y = sin(((noiseFloat - 0.3) * TWO_PI) * 10);
     
    vel.add(noiseVec);
    vel.div(ParSpeedRedFactor);
    pos.add(vel);
     
    if(1.0-(age/lifeTime) == 0){
     isDead = true;
    }
     
    //if we have the lines, respect the space for them
    if (linesMode){
        if(pos.x < v0_x || pos.x > v1_x || pos.y < 0 || pos.y > height){
           isDead = true;
           age = lifeTime;
        }
    } else { //else grab the whole screen as limit to kill the particles
        if(pos.x < 0 || pos.x > width || pos.y < 0 || pos.y > height){
           isDead = true;
           age = lifeTime;
        }
    }
     
    if(1.0-(age/lifeTime) != 0){
     age++; 
    }  
  }
   
  void draw(){   
    if (!isDead) {
      fill(0,ParticleAlpha);
      noStroke();
      ellipse(pos.x, pos.y, 1-(age/lifeTime), 1-(age/lifeTime));
    }
  }

}

