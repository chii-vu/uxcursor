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
  cursorType = CursorType.AREA;
  // Test with sample condition
  currentCondition = new Condition(cursorType, 10, 100, 50);
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
        displayedRecs = constructRecs(40, 30);
        trialStarted = true;
        currentCondition.startTrial();
      }
      renderRecs(displayedRecs);
      if (cursorType == CursorType.AREA) {
        // draw hitbox
        noFill();
        circle(mouseX, mouseY, areaHitBox * 2);
      }
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
        boolean isCorrect = target.isClicked();
        print(isCorrect ? "Target is clicked \n" : "Target not clicked \n");
        currentCondition.endTrial(isCorrect);
        if (currentTrialIndex < currentCondition.numTrials - 1) {
          currentTrialIndex++;
          trialStarted = false;
        } else {
          studyStage = ExperimentPhase.FINISHED;
        }
      }
      break;
    case FINISHED:
      break;
  }
}

void mouseMoved() {
  // Mouse's current position
  Point position = new Point(mouseX, mouseY);
  switch (studyStage) {
    case TRIAL:
      // Which rectangle is closest to the cursor?

      // reset default values to track closest rectangle and distance -- Sorry this feels a bit messy!
      Rectangle closestRectangle = displayedRecs.get(0);
      float closestDistance = 10000;

      // calculate distances between all rectangles and cursor
      for (int i = 0; i < displayedRecs.size(); i++) {
        Rectangle currentRectangle = displayedRecs.get(i);
        // Resetting all rectangles to false
        currentRectangle.isTargeted = false;
        float distance = distanceFromPointToRec(position, currentRectangle);
        // If currently the closest, update values
        if (distance < closestDistance) {
          closestRectangle = currentRectangle;
          closestDistance = distance;
        }
      }

      // mark closest rectangle -- depending on cursor type
      switch (cursorType) {
        case STANDARD:
          // Is the cursor on the closest rectangle
          if (closestDistance <= 0) {
            closestRectangle.isTargeted = true;
          }
          break;
        case AREA:
          // Is the closest rectangle within the area's hitbox
          if (closestDistance <= areaHitBox) {
            closestRectangle.isTargeted = true;
          }
          break;
        case BUBBLE:
          // No limits on Bubble - whoever is closest is targeted
          closestRectangle.isTargeted = true;
          break;
      }
      break;
  }
}

public ArrayList<Rectangle> constructRecs(int recHeight, int recDistance) {
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
  for (int i = 0; i < recs.size(); i++) {

    // color
    if (recs.get(i).isTarget) {
      fill(0, 200, 0);
    } else {
      fill(255, 255, 255);
    }

    // stroke - blue if hovered on
    if (recs.get(i).isTargeted) {
      stroke(0, 0, 255);
    } else {
      stroke(0, 0, 0);
    }

    // draw
    quad(recs.get(i).topLeft.x, recs.get(i).topLeft.y,
      recs.get(i).topRight.x, recs.get(i).topRight.y,
      recs.get(i).bottomRight.x, recs.get(i).bottomRight.y,
      recs.get(i).bottomLeft.x, recs.get(i).bottomLeft.y);
  }
}

public float distanceFromPointToRec(Point p, Rectangle rec) {
  float dx = max(rec.topLeft.x - p.x, 0, p.x - rec.topRight.x);
  float dy = max(rec.topLeft.y - p.y, 0, p.y - rec.bottomLeft.y);
  float distance = sqrt(dx * dx + dy * dy);
  return distance;
}
