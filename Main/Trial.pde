public class Trial {
  long startTime;
  long endTime;
  int error; // 0 for correct, 1 for incorrect
  float fittsID;

  public Trial() {
    this.startTime = System.currentTimeMillis();
  }

  public void endTrial(boolean isCorrect) {
    this.endTime = System.currentTimeMillis();
    this.error = isCorrect ? 0 : 1;
    this.fittsID = calculateFittsID();
  }

  private float calculateFittsID(float distance, float width) {
    return (float)(Math.log(distance / width + 1) / Math.log(2));
  }
}
