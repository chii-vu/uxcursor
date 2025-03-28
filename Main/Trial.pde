public class Trial {
  long startTime;
  long endTime;
  int error = 0;          
  float fittsID;
  Point startPosition; // Mouse position at the start and
  Point endPosition;   // End of the trial
  float targetWidth;   // Width of the target rectangle
  float averageDistance; // Rectangle average relative distance during trial

  public Trial(Point startPosition, float targetWidth, float averageDistance) {
    this.startTime = System.currentTimeMillis();
    this.startPosition = startPosition;
    this.targetWidth = targetWidth;
    this.averageDistance = averageDistance;
  }

  public void endTrial(boolean isCorrect, Point endPosition) {
    this.endTime = System.currentTimeMillis();
    this.error += isCorrect ? 0 : 1;
    this.endPosition = endPosition;
    this.fittsID = calculateFittsID();
  }

  private float calculateFittsID() {
    float distance = dist(startPosition.x, startPosition.y, endPosition.x, endPosition.y);
    return (float) (Math.log(distance / targetWidth + 1) / Math.log(2));
  }

  public String toCSV(CursorType cursorType, int targetSize) {
    long completionTime = endTime - startTime;
    return String.format("%s,%f,%d,%d,%d,%.2f",
        cursorType, averageDistance, targetSize, completionTime, error, fittsID);
  }
  
  public void addError(){
    error += 1;
  }
}
