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
