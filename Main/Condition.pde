import java.util.ArrayList;

public class Condition {
  CursorPhase cursorType;
  int numTrials;
  int targetDistance;
  int targetSize;
  ArrayList<Trial> trials;

  public Condition(CursorPhase cursorType, int numTrials, int targetDistance, int targetSize) {
    this.cursorType = cursorType;
    this.numTrials = numTrials;
    this.targetDistance = targetDistance;
    this.targetSize = targetSize;
    this.trials = new ArrayList<Trial>();
  }

  public void startTrial() {
    trials.add(new Trial());
  }

  public void endTrial(boolean isCorrect) {
    if (!trials.isEmpty()) {
      trials.get(trials.size() - 1).endTrial(isCorrect);
    }
  }

  public ArrayList<Trial> getTrials() {
    return trials;
  }
}
