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
     
    //// Pseudo code for different cursors
    //if (cursorType == area):
    //  return cursorOverlap();
    //else if (cursorType == bubble):
    //  // if the nearest target is saved, we can use that to compare
    //  return this == cursor.nearestTarget:
    //else:
    //  return mX >= topLeft.x && mX <= topRight.x && mY >= topLeft.y && mY <= bottomLeft.y;

    //return false;
  }
  
  ///**
  //* Checks for an overlap between a circle and a rectangle. Here, the circle is the cursor's selection area.
  //*/
  //private boolean cursorOverlap() {
  //  // check if there is overlap between the circular selection area and the rect
  //    if (topLeft.x <= circle.x <= topRight.x && topLeft.y <= circle.y <= bottomLeft.y):
  //      return true;
      
  //    // if the area cursor overlaps on the vertical edges of the rect
  //    if (((topLeft.x >= circle.x - radius && topLeft.x <= circle.x + radius) || 
  //         (topRight.x >= circle.x - radius && topRight.x <= circle.x + radius)) &&
  //         (circle.y >= topLeft.y && circle.y <= bottomLeft.y)):
  //      return true;
        
  //    // if the area cursor overlaps on the horizontal edges of the rect
  //    if (((topLeft.y >= circle.y - radius && topLeft.y <= circle.y + radius) || 
  //         (bottomLeft.y >= circle.y - radius && bottomLeft.y <= circle.y + radius)) &&
  //         (circle.x >= topLeft.x && circle.x <= topRight.x)):
  //      return true; 
      
  //    // if the corners overlap with the area cursor
  //    for every corner of the rectangle:
  //      if (sq(circle.x - corner.x) + sq(circle.y - corner.y) <= sq(circle.radius):
  //        return true;
      
  //    return false;
  //}
}
