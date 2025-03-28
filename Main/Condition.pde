import java.util.ArrayList;

public class Condition {
  CursorType cursorType;
  int numTrials;
  int numRecs;
  int targetSize;
  float averageDistance = 0.0f; //hold the average distance value for the next created trial
  ArrayList<Trial> trials;

  public Condition(CursorType cursorType, int numTrials, int numRecs, int targetSize) {
    this.cursorType = cursorType;
    this.numTrials = numTrials;
    this.numRecs = numRecs;
    this.targetSize = targetSize;
    this.trials = new ArrayList<Trial>();
  }

  public void startTrial(Point startPosition) {
    trials.add(new Trial(startPosition, targetSize, averageDistance));
  }

  public void endTrial(boolean isCorrect, Point endPosition) {
    if (!trials.isEmpty()) {
      trials.get(trials.size() - 1).endTrial(isCorrect, endPosition);
    }
  }
  
  public void addError(){
    if (!trials.isEmpty()) {
      trials.get(trials.size() - 1).addError();
    }
  }

  public ArrayList<Trial> getTrials() {
    return trials;
  }
  
  public void printTrialsCSV() {
    String timestamp = year() + "_" + month() + "_" + day() + "__" + hour() + "_" + minute() + "_" + second();
    String filename = "results/" + cursorType + "_" + numRecs + "_" + targetSize + "__" + timestamp + ".csv";
    PrintWriter output = createWriter(filename);
    
    // Print CSV header
    output.println("CursorType,AverageDistance,TargetSize,CompletionTime,Error,FittsID");
    
    int count = 0;
    // the number of trials we don't record
    int practiceTrials = 5;
    for (Trial trial : trials) {
      count++;
      if(count > practiceTrials){
        output.println(trial.toCSV(cursorType, targetSize));
      }
    }
    
    output.flush();
    output.close();
    println("Saved results to " + filename);
  }
}
