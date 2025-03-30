// HYPER PARAMS
final int REC_WIDTH = 200;

// rectangles
ArrayList<Rectangle> displayedRecs;
Rectangle target;
ExperimentPhase studyStage;
// variable use for debugging/testing
boolean trialStarted = false;
// current cursor in use
CursorType cursorType;
// radius size of Area Cursor hitbox
float areaHitBox = 35;

// Condition management
ConditionManager conditionManager;
int currentTrialIndex = 0;

// Mouse position tracking
Point trialStartPosition;

/**
 * Enum representing the types of cursors
 */
public enum CursorType {
  STANDARD,
  AREA,
  BUBBLE
}

/**
 * Enum representing different phases of experiment
 */
public enum ExperimentPhase {
  INSTRUCTIONS,
  BEFORE_TRIAL,
  TRIAL,
  BETWEEN_CONDITIONS,
  FINISHED
}

/**
 * Sets up experiment by setting initial experiment phase
 */
public void setup() {
  fullScreen();
  studyStage = ExperimentPhase.INSTRUCTIONS;
  conditionManager = new ConditionManager();
  
  // Set initial cursor type
  if (conditionManager.getCurrentCondition() != null) {
    cursorType = conditionManager.getCurrentCondition().cursorType;
  }
}

/**
 * Manages the display aspect of the experiment using the different phases
 */
void draw() {
  background(200);
  
  switch (studyStage) {
    case INSTRUCTIONS:
      displayCenteredText("Instructions\nClick on the target rectangle\n\n" + 
                         "Condition " + conditionManager.getCurrentConditionNumber() + 
                         " of " + conditionManager.getTotalConditions() + 
                         "\nCursor: " + cursorType + 
                         "\nTargets: " + conditionManager.getCurrentCondition().numRecs + 
                         "\nSize: " + conditionManager.getCurrentCondition().targetSize);
      break;
    case BEFORE_TRIAL:
      displayCenteredText("Before trial " + (currentTrialIndex + 1) + 
                         " of " + conditionManager.getCurrentCondition().numTrials + 
                         "\nClick to start");
      break;
    case TRIAL:
      if (!trialStarted) {
        displayedRecs = constructRecs(conditionManager.getCurrentCondition());
        trialStarted = true;
        trialStartPosition = new Point(mouseX, mouseY);
        lookForSelectedTarget(trialStartPosition);
        conditionManager.getCurrentCondition().startTrial(trialStartPosition);
      }
      renderRecs(displayedRecs);
      drawHitbox();
      break;
    case FINISHED:
      displayCenteredText("Your job is complete, please look at the console for your test results.");
      break;
    case BETWEEN_CONDITIONS:
      displayCenteredText("Condition completed\nClick to continue to next condition");
      break;
  }
}

/**
 * Displays centred text
 */
void displayCenteredText(String text) {
  fill(0, 0, 0);
  textSize(25);
  textAlign(CENTER);
  text(text, width / 2, height / 2);
}

/**
 * Manages mouse pressed events. Moves through the trial and records final trial data.
 */
void mousePressed() {
  switch (studyStage) {
    case INSTRUCTIONS:
      studyStage = ExperimentPhase.BEFORE_TRIAL;
      break;

    case BEFORE_TRIAL:
      studyStage = ExperimentPhase.TRIAL;
      break;

    case TRIAL:
      if (target != null) {
        boolean isCorrect = target.isTargeted;  // Use the flag set in mouseMoved()

        // Record the mouse position when the trial ends
        Point trialEndPosition = new Point(mouseX, mouseY);
        
        // If not clicked, record error
        if(!isCorrect){
          conditionManager.getCurrentCondition().addError();
          // Five errors are allowed - otherwise end trial
          if(conditionManager.getCurrentCondition().getError() < 5){
            break;
          }
        }
        // End trial
        conditionManager.getCurrentCondition().endTrial(trialEndPosition);

        if (currentTrialIndex < conditionManager.getCurrentCondition().numTrials - 1) {
          currentTrialIndex++;
          trialStarted = false;
        } else {
          // Save data for this condition
          conditionManager.getCurrentCondition().printTrialsCSV();
          
          if (conditionManager.hasMoreConditions()) {
            studyStage = ExperimentPhase.BETWEEN_CONDITIONS;
          } else {
            studyStage = ExperimentPhase.FINISHED;
          }
        }
      }
      break;

    case BETWEEN_CONDITIONS:
      conditionManager.nextCondition();
      if (conditionManager.hasMoreConditions()) {
        currentTrialIndex = 0;
        trialStarted = false;
        cursorType = conditionManager.getCurrentCondition().cursorType;
        studyStage = ExperimentPhase.INSTRUCTIONS;
      }
      break;

    case FINISHED:
      break;
  }
}

/**
 * Manages mouse movement events only during the trial phase. Updates the selected target based on mouse position.
 */
void mouseMoved() {
  if (studyStage != ExperimentPhase.TRIAL) return;
  lookForSelectedTarget(new Point(mouseX, mouseY));

}

/**
 * Creates an ArrayList of rectangles based on the experiment conditions and chooses a random rectangle to be
 * the target.
 *
 * @param condition The condition of the experiment, defines rectangle size and distance between them.
 * @return An ArrayList of Rectangles
 */
public ArrayList<Rectangle> constructRecsGrid(Condition condition) {
  int recHeight = condition.targetSize;
  int recDistance = 50;
  int totalWidth = REC_WIDTH + recDistance;
  int totalHeight = recHeight + recDistance;
  int numX = width / (totalWidth);
  int numY = height / (totalHeight);
  int outsideXPadding = (width - (numX * totalWidth) + recDistance) / 2;
  int outsideYPadding = (height - (numY * totalHeight) + recDistance) / 2;

  // Pick random target
  int randX = (int) random(0, numX);
  int randY = (int) random(0, numY);

  ArrayList<Rectangle> createdRecs = new ArrayList<Rectangle>();
  for (int i = 0; i < numX; i++) {
    for (int j = 0; j < numY; j++) {
      Point topLeft = new Point(outsideXPadding + i * totalWidth, outsideYPadding + j * totalHeight);
      Point topRight = new Point(topLeft.x + REC_WIDTH, topLeft.y);
      Point bottomLeft = new Point(topLeft.x, topLeft.y + recHeight);
      Point bottomRight = new Point(topLeft.x + REC_WIDTH, topLeft.y + recHeight);

      Rectangle newRec = new Rectangle(topLeft, topRight, bottomLeft, bottomRight);

      // assign target
      if (i == randX && j == randY) {
        newRec.isTarget = true;
        target = newRec;
      }

      createdRecs.add(newRec);
    }
  }
  return createdRecs;
}

public ArrayList<Rectangle> constructRecs(Condition condition) {
  ArrayList<Rectangle> createdRecs = new ArrayList<Rectangle>();
  
  // Calculate max no. of rectangles that can fit on the screen
  int maxRecsX = width / REC_WIDTH;
  int maxRecsY = height / condition.targetSize;
  int maxRecs = maxRecsX * maxRecsY;

  // Cap no. of rectangles to maxRecs
  if (condition.numRecs > maxRecs) {
    println("Warning: Too many rectangles for the screen. Adjusting to fit.");
    condition.numRecs = maxRecs;
  }

  //first rec
  int x = (int)random(0, width - REC_WIDTH);
  int y = (int)random(0, height - condition.targetSize);
  Point topLeft = new Point(x, y);
  Point topRight = new Point(topLeft.x + REC_WIDTH, topLeft.y);
  Point bottomLeft = new Point(topLeft.x, topLeft.y + condition.targetSize);
  Point bottomRight = new Point(topLeft.x + REC_WIDTH, topLeft.y + condition.targetSize);
  Rectangle newRec = new Rectangle(topLeft, topRight, bottomLeft, bottomRight);
  newRec.isTarget = true;
  target = newRec;
  createdRecs.add(newRec);
  
  //the rest of the recs
  int numPlacedRecs = 1;
  int maxRetries = 100; // Max retries for placing a rectangle

  // Keep placing rectangles until can't place any more or all are placed
  outer:
  while (numPlacedRecs < condition.numRecs) {
    int retries = 0;
    while (retries < maxRetries) {
      int newx = (int)random(0, width - REC_WIDTH);
      int newy = (int)random(0, height - condition.targetSize);

      boolean overlaps = false;
      for (Rectangle rec : createdRecs) {
        if (Math.abs(newx - rec.topLeft.x) < REC_WIDTH && Math.abs(newy - rec.topLeft.y) < condition.targetSize) {
          overlaps = true;
          break;
        }
      }

      if (!overlaps) {
        topLeft = new Point(newx, newy);
        topRight = new Point(topLeft.x + REC_WIDTH, topLeft.y);
        bottomLeft = new Point(topLeft.x, topLeft.y + condition.targetSize);
        bottomRight = new Point(topLeft.x + REC_WIDTH, topLeft.y + condition.targetSize);
        newRec = new Rectangle(topLeft, topRight, bottomLeft, bottomRight);
        createdRecs.add(newRec);
        numPlacedRecs++;
        continue outer;
      }

      retries++;
    }

    // If retries are exhausted and still can't place a rectangle, break out of the loop
    println("Warning: Could not place all rectangles. Reducing to " + numPlacedRecs + " rectangles.");
    condition.numRecs = numPlacedRecs;
    break;
  }
  
  //calculate average distance
  float avDistance = 0;
  float numPairs = 0;
  for (int i = 0; i < createdRecs.size(); i++) {
    for (int j = i+1; j < createdRecs.size(); j++) {
      avDistance += euclideanDistance(createdRecs.get(i).topLeft, createdRecs.get(j).topLeft);
      numPairs++;
    }
  }
  condition.averageDistance = avDistance/numPairs;
  
  return createdRecs;
}

/**
 * Renders the given list of rectangles
 *
 * @param recs ArrayList of rectangles to display
 */
public void renderRecs(ArrayList<Rectangle> recs) {
  for (Rectangle rec : recs) {
    // Fill colour 
    fill(rec.isTarget ? color(0, 200, 0) : color(255));
    
    if (rec.isTargeted) {
      strokeWeight(3);
      // Choose stroke colour based on cursor type
      switch(cursorType) {
        case AREA:
          stroke(0, 0, 255); // Blue for area cursor
          break;
        case STANDARD:
          stroke(0, 255, 0); // Green for standard cursor
          break;
        default:
          strokeWeight(1);
          stroke(0);
          break;
      }
    } else {
      stroke(0);
      strokeWeight(1);
    }
    
    // Draw the rectangle
    quad(rec.topLeft.x, rec.topLeft.y,
         rec.topRight.x, rec.topRight.y,
         rec.bottomRight.x, rec.bottomRight.y,
         rec.bottomLeft.x, rec.bottomLeft.y);
    
    // For bubble cursor, add extra bubble on targeted rectangle
    if (rec.isTargeted && cursorType == CursorType.BUBBLE) {
      noStroke();
      fill(255, 0, 0, 100);
      quad(rec.topLeft.x - 5, rec.topLeft.y - 5,
           rec.topRight.x + 5, rec.topRight.y - 5,
           rec.bottomRight.x + 5, rec.bottomRight.y + 5,
           rec.bottomLeft.x - 5, rec.bottomLeft.y + 5);
    }
  }
}

/**
 * Calculates the distance from a given point to the closest edge of a rectangle.
 *
 * @param p A point from which the distance to a rectangle is calculated
 * @param rec The rectangle from which the distance to the point is measured.
 * @return The distance
 */
public float distanceFromPointToRec(Point p, Rectangle rec) {
  float dx = max(rec.topLeft.x - p.x, 0, p.x - rec.topRight.x);
  float dy = max(rec.topLeft.y - p.y, 0, p.y - rec.bottomLeft.y);
  return sqrt(dx * dx + dy * dy);
}

public float euclideanDistance(Point p1, Point p2) {
  float xdiff = Math.abs(p1.x - p2.x);
  float ydiff = Math.abs(p1.y - p2.y);
  return (float)Math.sqrt(xdiff * xdiff + ydiff * ydiff);
}


/**
 * Calculates the overlapping area between a circle and a rectangle.
 *
 * @param cursor The point at the centre of the circle
 * @param rec The rectangle
 * @param radius The radius of the circle
 * @return The area of the overlap
 */
float computeOverlapArea(Point cursor, Rectangle rec, float radius) {
  float circleLeft = cursor.x - radius;
  float circleRight = cursor.x + radius;
  float circleTop = cursor.y - radius;
  float circleBottom = cursor.y + radius;

  float rectLeft = rec.topLeft.x;
  float rectRight = rec.topRight.x;
  float rectTop = rec.topLeft.y;
  float rectBottom = rec.bottomLeft.y;

  float overlapWidth = max(0, min(circleRight, rectRight) - max(circleLeft, rectLeft));
  float overlapHeight = max(0, min(circleBottom, rectBottom) - max(circleTop, rectTop));

  return overlapWidth * overlapHeight;
}

/**
 * Computes the radius of the bubble cursor
 *
 * @param cursor The current position of the cursor
 * @return The bubble radius
 */
float computeBubbleRadius(Point cursor) {
  float minDistance = Float.MAX_VALUE;
  float maxDistance = 0;

  for (Rectangle rec : displayedRecs) {
    float distance = distanceFromPointToRec(cursor, rec);
    if (distance < minDistance) {
      minDistance = distance;
    }
    if (distance > maxDistance) {
      maxDistance = distance;
    }
  }

  float radius = (minDistance < maxDistance) ? minDistance : maxDistance * 0.5;
  return max(radius, 10);  // Set min size so it doesn't return a speck
}

/**
 * Draws the hitbox around the cursor. For an area cursor, draws a simple circle; for 
 * a bubble cursor, draws a bubble effect with a dynamic radius.
 */
void drawHitbox() {
  if (cursorType == CursorType.AREA) {
      // draw hitbox
      noFill();
      circle(mouseX, mouseY, areaHitBox * 2);
  } else if (cursorType == CursorType.BUBBLE) {
      float bubbleRadius = computeBubbleRadius(new Point(mouseX, mouseY));
      noStroke();
      fill(255, 0, 0, 100);
      circle(mouseX, mouseY, bubbleRadius * 2);
  }
}

/**
 * Looks for a selected rectangle as a target; does this based on the current cursor position, and the 
 * type of cursor.
 *
 * @param position The current position of the cursor.
 */
void lookForSelectedTarget(Point position) {
  for (Rectangle rec : displayedRecs) {
    rec.isTargeted = false;
  }

  Rectangle selectedRectangle = null;

  switch (cursorType) {
    case STANDARD:
      for (Rectangle rec : displayedRecs) {
        if (rec.contains(position)) {
          selectedRectangle = rec;
          break;
        }
      }
      break;

    case AREA:
      float maxOverlap = 0;
      for (Rectangle rec : displayedRecs) {
        float overlapArea = computeOverlapArea(position, rec, areaHitBox);
        if (overlapArea > maxOverlap) {
          maxOverlap = overlapArea;
          selectedRectangle = rec;
        }
      }
      break;

    case BUBBLE:
      float bubbleRadius = computeBubbleRadius(position);
      float closestDistance = Float.MAX_VALUE;

      for (Rectangle rec : displayedRecs) {
        float distance = distanceFromPointToRec(position, rec);
        if (distance <= bubbleRadius && distance <= closestDistance) {
          closestDistance = distance;
          selectedRectangle = rec;
        }
      }
      break;
  }

  if (selectedRectangle != null) {
    selectedRectangle.isTargeted = true;
  }
}
