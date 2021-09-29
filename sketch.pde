Uploader u;

void setup() {
  size(1000, 1000);
  
  /* More setup goes here */
  
  u = new Uploader("pool.name");
}

void draw() {
  
  
}

void keyPressed() {
  if (key == CODED && keyCode == UP) u.capture();
  
  /* Other keyPressed handlers go here */
}
