public class Rectangle {
  boolean isTarget;
  Point topLeft;
  Point topRight;
  Point bottomLeft;
  Point bottomRight;
  boolean isTargetted;
  
  
  public Rectangle(Point p1, Point p2, Point p3, Point p4) {
    topLeft = p1;
    topRight = p2;
    bottomLeft = p3;
    bottomRight = p4;
  }
  
  public boolean isClicked() {
     // If the current rectangle is targetted - then it will be the one clicked
     return isTargetted;
  }
}
