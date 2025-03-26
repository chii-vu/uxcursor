import java.util.ArrayList;

public class Condition {
  CursorType cursorType;
  int numTrials;
  int numRecs;
  float averageDistance = 0.0f;
  int targetSize;
  ArrayList<Trial> trials;

  public Condition(CursorType cursorType, int numTrials, int numRecs, int targetSize) {
    this.cursorType = cursorType;
    this.numTrials = numTrials;
    this.numRecs = numRecs;
    this.targetSize = targetSize;
    this.trials = new ArrayList<Trial>();
  }

  public void startTrial(Point startPosition) {
    trials.add(new Trial(startPosition, targetSize));
  }

  public void endTrial(boolean isCorrect, Point endPosition) {
    if (!trials.isEmpty()) {
      trials.get(trials.size() - 1).endTrial(isCorrect, endPosition);
    }
  }

  public ArrayList<Trial> getTrials() {
    return trials;
  }

  public void printTrialsCSV() {
    // Print CSV header
    System.out.println("CursorType,TargetDistance,TargetSize,CompletionTime,Error,FittsID");
    // Print each trial in CSV format (we'll write this to a file later)
    for (Trial trial : trials) {
      System.out.println(trial.toCSV(cursorType, averageDistance, targetSize));
    }
  }
}
