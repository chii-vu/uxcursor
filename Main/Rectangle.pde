public class Rectangle {
  boolean isTarget;
  Point topLeft;
  Point topRight;
  Point bottomLeft;
  Point bottomRight;
  boolean isClosest;
  
  
  public Rectangle(Point p1, Point p2, Point p3, Point p4) {
    topLeft = p1;
    topRight = p2;
    bottomLeft = p3;
    bottomRight = p4;
  }
  
  public boolean isClicked(int mX, int mY) {
     
     switch(cursorType){
       case STANDARD:
         return mX >= topLeft.x && mX <= topRight.x && mY >= topLeft.y && mY <= bottomLeft.y;
       case AREA:
         // Must be within the circle and the closest to the mouse
         return cursorOverlap(mX, mY) & isClosest;
       case BUBBLE:
         // Must be the closest rectangle
         return isClosest;
     }
     return false;
  }
  
  ///**
  //* Checks for an overlap between a circle and a rectangle. Here, the circle is the cursor's selection area.
  //*/
  private boolean cursorOverlap(int mX, int mY){
   // check if the radius of the circle is greater than the distance to the rectangle.
   Point position = new Point(mX, mY);
   float distance = distanceFromPointToRec(position, this);
   
   if(areaHitBox  > distance){
     return true;
   }
   return false;
  }
}
