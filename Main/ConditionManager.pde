/**
 * Set of conditions for the experiment.
 */
public class ConditionManager {
  ArrayList<Condition> allConditions;
  int currentConditionIndex;
  
  public ConditionManager() {
    allConditions = new ArrayList<Condition>();
    ArrayList<Condition> standardConditions = new ArrayList<Condition>();
    ArrayList<Condition> areaConditions = new ArrayList<Condition>();
    ArrayList<Condition> bubbleConditions = new ArrayList<Condition>();
    currentConditionIndex = 0;
    
    // TODO: adjust based on testing
    CursorType[] cursorTypes = {CursorType.STANDARD, CursorType.AREA, CursorType.BUBBLE};
    int[] targetCounts = {5, 15, 40, 60, 80};
    int[] targetSizes = {10, 30, 50};
    
    // Some triple loop action to create all the combinations
    for (CursorType ct : cursorTypes) {
      for (int count : targetCounts) {
        for (int size : targetSizes) {
          if(ct == CursorType.STANDARD){
            standardConditions.add(new Condition(ct, 20, count, size)); // 20 trials per condition
          }
          else if(ct == CursorType.AREA){
            areaConditions.add(new Condition(ct, 20, count, size)); // 20 trials per condition
          }
          else if(ct == CursorType.BUBBLE){
            bubbleConditions.add(new Condition(ct, 20, count, size)); // 20 trials per condition
          }
        }
      }
    }
    // Shuffle conditions per CursorType
    java.util.Collections.shuffle(standardConditions);
    java.util.Collections.shuffle(areaConditions);
    java.util.Collections.shuffle(bubbleConditions);
    
    // Add together
    allConditions.addAll(standardConditions);
    allConditions.addAll(areaConditions);
    allConditions.addAll(bubbleConditions);
    
  }
  
  // Getters
  public Condition getCurrentCondition() {
    if (currentConditionIndex < allConditions.size()) {
      return allConditions.get(currentConditionIndex);
    }
    return null;
  }
  
  public void nextCondition() {
    currentConditionIndex++;
  }
  
  public boolean hasMoreConditions() {
    return currentConditionIndex < allConditions.size();
  }
  
  public int getTotalConditions() {
    return allConditions.size();
  }
  
  public int getCurrentConditionNumber() {
    return currentConditionIndex + 1;
  }
}
