// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids
  Leader leader;

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids, leader);  // 
    }
    leader.run();
  }

  void addBoid(Boid b) {
    boids.add(b);
  }
}
