Flock flock;

void setup() {
  size(1024, 720);
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 150; i++) {
    flock.addBoid(new Boid(width/2,height/2));
  }
  flock.leader = new Leader(0,height/2);
  flock.disruptor = new Disruptor(width/2,height/5);
}

void draw() {
  background(1);
  flock.run();
}

// Add a new boid into the System
void mousePressed() {
  flock.addBoid(new Boid(mouseX,mouseY));
}
