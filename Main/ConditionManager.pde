/**
 * Set of conditions for the experiment.
 */
public class ConditionManager {
  ArrayList<Condition> allConditions;
  int currentConditionIndex;
  
  public ConditionManager() {
    allConditions = new ArrayList<Condition>();
    currentConditionIndex = 0;
    
    // TODO: adjust based on testing
    CursorType[] cursorTypes = {CursorType.STANDARD, CursorType.AREA, CursorType.BUBBLE};
    int[] targetCounts = {5, 15, 40, 60, 80};
    int[] targetSizes = {10, 30, 60};
    
    // Some triple loop action to create all the combinations
    for (CursorType ct : cursorTypes) {
      for (int count : targetCounts) {
        for (int size : targetSizes) {
          allConditions.add(new Condition(ct, 20, count, size)); // 20 trials per condition
        }
      }
    }
    
    // Shuffle conditions to avoid bias
    java.util.Collections.shuffle(allConditions);
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
