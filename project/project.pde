//HYPER PARAMS
final int REC_WIDTH = 200;

//rectangles
ArrayList<Rectangle> displayedRecs;


public void setup() {
  fullScreen();
  
  //example usage vv
  //Try varying the params below, and the width hyper param above
  displayedRecs = constructRecs(40, 30);
  renderRecs(displayedRecs);
}

public void draw() {}




public class Point {
  int x;
  int y;
  public Point(int x, int y) {
    this.x = x;
    this.y = y;
  }
}

//Rectangle class stores its top left point, and it's height
//Other three points are calculated using the REC_WIDTH constant, and its height
public class Rectangle {
  Point topLeftPoint;
  int recHeight;
  public Rectangle(Point p, int h) {
    topLeftPoint = p;
    recHeight = h;
  }
}


public ArrayList<Rectangle> constructRecs(int recHeight, int recDistance) {
   int totalWidth = REC_WIDTH + recDistance;
   int totalHeight = recHeight + recDistance;
   int numX = width / (totalWidth);
   int numY = height / (totalHeight);
   int outsideXPadding = (width - (numX * totalWidth) + recDistance) / 2;
   int outsideYPadding = (height - (numY * totalHeight) + recDistance) / 2;
   
   ArrayList<Rectangle> createdRecs = new ArrayList<Rectangle>();
   for (int i = 0; i < numX; i++) {
     for (int j = 0; j < numY; j++) {
       Point topLeft = new Point(outsideXPadding + i * totalWidth, outsideYPadding + j * totalHeight);
       Rectangle newRec = new Rectangle(topLeft, recHeight);
       createdRecs.add(newRec);
     }
   }
   return createdRecs;
}

public void renderRecs(ArrayList<Rectangle> recs) {
  for (int i = 0; i < recs.size(); i++) {
    int up = recs.get(i).topLeftPoint.y;
    int left = recs.get(i).topLeftPoint.x;
    int right = recs.get(i).topLeftPoint.x + REC_WIDTH;
    int down = recs.get(i).topLeftPoint.y + recs.get(i).recHeight;
    
    quad(left, up, right, up, right, down, left, down);
  }
}
