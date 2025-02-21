public class Rectangle {
  boolean isTarget;
  Point topLeft;
  Point topRight;
  Point bottomLeft;
  Point bottomRight;
  
  public Rectangle(Point p1, Point p2, Point p3, Point p4) {
    topLeft = p1;
    topRight = p2;
    bottomLeft = p3;
    bottomRight = p4;
  }
  
  public boolean isClicked(int mX, int mY) {
     return mX >= topLeft.x && mX <= topRight.x && mY >= topLeft.y && mY <= bottomLeft.y;
  }
}
