class Disruptor extends Bird{
  float angle;
  Disruptor(float x, float y) { //Constructor
    super(x,y);
    velocity.x = 2;
    velocity.y = 0;
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
    //changeVelocity();
    changeAcceleration();
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    position.add(velocity);
    acceleration.mult(0);
  }
  void changeAcceleration(){
    PVector centro = new PVector(width/2,height/2);
    PVector radio = PVector.sub(centro, position);
    float r = radio.mag();
    float v = velocity.mag();
    radio.normalize();
    acceleration = radio.mult((v*v)/r);
  }
}
