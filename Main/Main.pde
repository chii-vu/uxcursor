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

// Condition and Trial management
Condition currentCondition;
int currentTrialIndex = 0;

// Mouse position tracking
Point trialStartPosition;

// which cursor is in use?
public enum CursorType {
  STANDARD,
  AREA,
  BUBBLE
}

// State machine
public enum ExperimentPhase {
  INSTRUCTIONS,
  BEFORE_TRIAL,
  TRIAL,
  FINISHED
}

public void setup() {
  fullScreen();
  studyStage = ExperimentPhase.INSTRUCTIONS;
  cursorType = CursorType.BUBBLE;
  // Test with sample condition
  currentCondition = new Condition(cursorType, 10, 50, 30);
}

void draw() {
  background(200);
  /**
   * Part of the state machine that displays the process of the trials through all the conditions
   */
  switch (studyStage) {
    case INSTRUCTIONS:
      displayCenteredText("Instructions\nClick on the target rectangle");
      break;
    case BEFORE_TRIAL:
      displayCenteredText("Before condition\nClick to start the trial");
      break;
    case TRIAL:
      // example usage vv
      // Try varying the params below, and the width hyper param above
      if (!trialStarted) {
        displayedRecs = constructRecs(currentCondition);
        trialStarted = true;
        // Record the mouse position when the trial starts
        trialStartPosition = new Point(mouseX, mouseY);
        currentCondition.startTrial(trialStartPosition);
      }
      renderRecs(displayedRecs);
      drawHitbox();
      break;
    case FINISHED:
      displayCenteredText("Your job is complete, please look at the console for your test results.");
      break;
  }
}

void displayCenteredText(String text) {
  fill(0, 0, 0);
  textSize(25);
  textAlign(CENTER);
  text(text, width / 2, height / 2);
}

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
        currentCondition.endTrial(isCorrect, trialEndPosition);

        if (currentTrialIndex < currentCondition.numTrials - 1) {
          currentTrialIndex++;
          trialStarted = false;
        } else {
          studyStage = ExperimentPhase.FINISHED;
          currentCondition.printTrialsCSV();
        }
      }
      break;

    case FINISHED:
      break;
  }
}

void mouseMoved() {
  if (studyStage != ExperimentPhase.TRIAL) return;
  Point position = new Point(mouseX, mouseY);

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

public ArrayList<Rectangle> constructRecs(Condition condition) {
  int recHeight = condition.targetSize;
  int recDistance = condition.targetDistance;
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

public void renderRecs(ArrayList<Rectangle> recs) {
  for (Rectangle rec : recs) {
    // Fill colour
    fill(rec.isTarget ? color(0, 200, 0) : color(255));

    if (rec.isTargeted) {
      if (cursorType == CursorType.AREA) {
        // Blue border for area cursor target
        stroke(0, 0, 255);
        strokeWeight(3);
      } else if (cursorType == CursorType.AREA) {
        // Green border for standard cursor target
        stroke(0, 255, 0);
        strokeWeight(3);
      }
    } else {
      // No outline for non-targeted rectangles
      stroke(0);
      strokeWeight(1);
    }

    // Draw rectangle
    quad(rec.topLeft.x, rec.topLeft.y,
         rec.topRight.x, rec.topRight.y,
         rec.bottomRight.x, rec.bottomRight.y,
         rec.bottomLeft.x, rec.bottomLeft.y);
         
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

public float distanceFromPointToRec(Point p, Rectangle rec) {
  float dx = max(rec.topLeft.x - p.x, 0, p.x - rec.topRight.x);
  float dy = max(rec.topLeft.y - p.y, 0, p.y - rec.bottomLeft.y);
  return sqrt(dx * dx + dy * dy);
}

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
* 
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
