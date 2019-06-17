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
