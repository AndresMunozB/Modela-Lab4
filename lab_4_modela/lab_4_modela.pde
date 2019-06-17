Flock flock;

void setup() {
  size(1024, 720);
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 150; i++) {
    flock.addBoid(new Boid(width/2,height/2));
  }
  flock.leader = new Leader(0,height/2);
  flock.disruptor = new Disruptor(width/2,0);
}

void draw() {
  background(1);
  flock.run();
}

// Add a new boid into the System
void mousePressed() {
  flock.addBoid(new Boid(mouseX,mouseY));
  System.out.print(mouseX + ",");
  System.out.print(mouseY + " - ");
}



// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids
  Leader leader;
  Disruptor disruptor;

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids, leader, disruptor);  // 
    }
    leader.run();
    disruptor.run();
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

}

public class Colour{
  int r;
  int g;
  int b;
  Colour(int r, int g, int b){
    this.r = r;
    this.g = g;
    this.b = b;
  }
}
public class Bird{
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  Colour colour;
  
  
  Bird(float x, float y){
    position = new PVector(x, y);
    velocity = new PVector(0,0);
    acceleration = new PVector(0, 0);
    maxspeed = 1.8;
    maxforce = 0.03;
  }
  
  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    fill(colour.r,colour.g,colour.b); //Color de llenado del triangulo
    stroke(colour.r,colour.g,colour.b); //Color del borde del triangulo
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2); //Vertices del pajaro (triangulo)
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }
  
  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  } 
}

// The Boid class
class Boid extends Bird{

  Boid(float x, float y) {
    super(x,y);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    r = 2.0; //Tamaño del pajaro
    colour = new Colour(255,255,255);
  }

  void run(ArrayList<Boid> boids, Leader leader, Disruptor disruptor) {
    flock(boids, leader, disruptor);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids, Leader leader, Disruptor disruptor) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    PVector sepLeader = separateLeader(leader); // acercarse al lider
    PVector aliLeader = alignLeader(leader); // acercarse al lider
    PVector cohLeader = cohesionLeader(leader); // acercarse al lider
    PVector getAway = getAwayDisruptor(disruptor); // alejarse del disruptor
    
    // Arbitrarily weight these forces p
    sep.mult(2.0);
    ali.mult(1);
    coh.mult(1);
    sepLeader.mult(1.2);
    aliLeader.mult(1.2);
    cohLeader.mult(2.0);
    getAway.mult(2.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(sepLeader);
    applyForce(aliLeader);
    applyForce(cohLeader);
    applyForce(getAway);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many+++
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  
  
  // Separation
  // Method checks for nearby boids and steers away
  PVector separateLeader (Leader leader) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    
    float d = PVector.dist(position, leader.position);
    // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
    if ((d > 0) && (d < desiredseparation)) {
      // Calculate vector pointing away from neighbor
      PVector diff = PVector.sub(position, leader.position);
      diff.normalize();
      diff.div(d);        // Weight by distance
      steer.add(diff);
      count++;            // Keep track of how many
    }
    
    // Average -- divide by how many+++
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector alignLeader (Leader leader) {
    //float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    
    float d = PVector.dist(position, leader.position);
    //if ((d > 0) && (d < neighbordist)) {
      sum.add(leader.velocity);
      count++;
    //}
    
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesionLeader (Leader leader) {
    //float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    
    float d = PVector.dist(position, leader.position);
    //if ((d > 0) && (d < neighbordist)) {
      sum.add(leader.position); // Add position
      count++;
    //}
   
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  PVector getAwayDisruptor(Disruptor disruptor){
    float neighbordist = 250;
    float a = -50;
    float d = PVector.dist(position, disruptor.position);
    if ((d > 0) && (d < neighbordist)) {
        PVector towards = seek(disruptor.position);
        towards = towards.mult(a/d);
        //System.out.println(towards);
        return towards;
     }
     else{
       return new PVector(0,0);
     }
     
     
    
  }
  
}

// Leader Class
class Leader extends Bird{  
  float angle = 0;
  boolean flag = true;
  Leader(float x, float y) { //Constructor
    super(x,y);
    velocity.x = -2;
    velocity.y = 0;
    velocity.limit(maxspeed);
    r = 5.0; //Tamaño del pajaro 
    colour = new Colour(38, 132, 232);
  }
  
  void run() {
    update();
    borders();
    render();
  }
  
  // Method to update position
  void update() {
    changeVelocity();
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    position.add(velocity);
    acceleration.mult(0);
  }
  
  void changeVelocity(){
    if(flag){
      angle += PI/720;
    }
    else{
      angle -= PI/720;
    }
    if(angle > PI/3){
      flag = false;
    }
    else if(angle < -PI/4){
      flag = true;
    }
    velocity.x = 1.8*cos(angle);
    velocity.y = 1.8*sin(angle);
  }
  
}

class Disruptor extends Bird{
  float angle;
  Disruptor(float x, float y) { //Constructor
    super(x,y);
    velocity.x = 0;
    velocity.y = 2;
    velocity.limit(maxspeed);
    r = 5.0; //Tamaño del pajaro
    colour = new Colour(235, 66, 36);
  }
  
  void run() {
    update();
    borders();
    render();
  }
  
  void update() {
    changeVelocity();
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    position.add(velocity);
    acceleration.mult(0);
  }
  
  void changeVelocity(){
    
    angle += PI/360;
    velocity.x = 2*cos(angle);
    velocity.y = 2*sin(angle);
  }
  
  // Method to update position
  
}
