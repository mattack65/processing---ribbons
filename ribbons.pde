import processing.svg.*;

BezierLine bigLine;

int border = 50;  // which part of the canvas should not be used to decrease the chance that lines go outside the canvas
float strokeweight = 0.3;
boolean creationLinesVisible = false;
boolean helperlinePointsVisible = false;

// all about making movies and animations (experimental)
boolean animate = true;
boolean animationHelperLinesInitiated = false;
boolean pauseAnimation = false;
PVector[][][] animationPointVectors;
boolean helperlineIntervallsVisible = false;

BezierLine[] helperLineArr;
int helperLinesNo; // will be set automatically

// Parameters to play with:
///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////
// How many helper lines and how many points per helper line. Expand as you wish.
// You can change the number of lines by adding another number to the array.
// Each number defines the number of random points that define that line.
// It needs a minimum of 2 entries, each entry >= 2
// This is the most important parameter. The more points, the more complex the drawing.

int[] helperLinePoints = {6, 3, 2};

// other samples that work well
// int[] helperLinePoints = {2,4,5};
// int[] helperLinePoints = {2,3};

int connectors = 500;  // number of perceived lines, roughly (can be changed while the program runs with "+" or "-")

// draw straight lines instead of a bezier curve; looks completely different
boolean straightLines = false;

// how bulgy should the curves be?
float swell = 0.3;

// close each helper line onto itself
boolean closeHelperLines = true;

// color some parts of the image differently
boolean multiColor = false;

// how long will each path be in the SVG file (if 1 pixel eq. 1 mm, adjust accordingly)
int max_path_length_in_m = 500;

///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////

int stillFrameCounter = 0;

void setup () {
  size(1410, 1000);
  // size(2048, 1080); // 2K for movies
  background(255);
  strokeWeight(strokeweight);

  helperLinesNo = helperLinePoints.length;
  helperLineArr = new BezierLine[helperLinesNo];

  if (connectors == 0) {
    // estimate the needed connectors
    //TBD:
    //connectors = helperLinePoints[0] * helperLinePoints[1] *
  }

  if (!animate) {
    createRndHelperLines();
    drawLines();
  }
}

BezierLine createRndBezierLine(int numPoints) {
  // create a bezierLIne with a number of random points on the canvas
  BezierLine line = new BezierLine(swell);
  for (int i = 0; i < numPoints; i++) {
    line.addPoint(new PVector(border + random(width - 2 * border), border + random(height - 2 * border)));
  }
  if (closeHelperLines && numPoints > 2) {
    line.closeCurve();
  }
  return line;
}

void createRndHelperLines() {
  // several alternatives available
  pureRndHelperLines();
  // translatedRotatedHelperLines(); // there must be exactly two helper lines defined
  // wernersRndHelperLines(); // there must be exactly four helper lines defined
  // noisySunHelperLines();
}

void pureRndHelperLines() {
  // create a number of completely random bezier lines with given number of anchor points
  for (int j = 0; j < helperLinesNo; j++) {
    helperLineArr[j] = createRndBezierLine(helperLinePoints[j]);
  }
}

void translatedRotatedHelperLines() {
  // create a random helper line first and then create a copy that is translated and rotated.
  // optionally add some random noise to the copy
  // this will result in ribbon or hose like patterns
  BezierLine line1 = createRndBezierLine(helperLinePoints[0]);
  helperLineArr[0] = line1;

  BezierLine line2 = new BezierLine(swell);
  // Define the translation vector
  PVector addVector = new PVector(50, 50);
  // Convert degrees to radians because PVector.rotate() works with radians
  float radians = radians(10);  // your rotation angle in degrees

  // Define the center of rotation
  PVector centerOfRotation = new PVector(width/2, height/2);  // (cx, cy) is the point around which you want to rotate

  for (PVector point : line1.anchorPoints) {
    // Copy the point, rotate it around (0,0), then translate it
    PVector rotatedPoint = point.copy()
      .sub(centerOfRotation)  // Step 1: Move to origin
      .rotate(radians)        // Step 2: Rotate
      .add(centerOfRotation)  // Step 3: Translate back
      .add(addVector);        // Step 4: Final translation
    // alternative:
    // .add(new PVector(random(50), random(50)));
    // Add the new rotated and translated point to the new line
    line2.addPoint(rotatedPoint);
  }

  if (closeHelperLines) {
    line2.closeCurve();
  }
  helperLineArr[1] = line2;
}


void wernersRndHelperLines() {
  // Werner suggested to make the ribbons more voluminous
  // We achieve this by creating two random lines and a copy of each (possibly rotated and random noise as well)
  // this well result in more "pumped up" structures
  BezierLine line0 = createRndBezierLine(helperLinePoints[0]);
  helperLineArr[0] = line0;

  BezierLine line1 = new BezierLine(swell);
  // copy and translate the first line
  PVector addVector = new PVector(-60, 30);
  for (PVector point : line0.anchorPoints) {
    // line2.addPoint(point.copy().add(new PVector(random(100), random(100))));
    line1.addPoint(point.copy().add(addVector));
  }
  if (closeHelperLines) {
    line1.closeCurve();
  }


  BezierLine line2 = createRndBezierLine(helperLinePoints[2]);

  BezierLine line3 = new BezierLine(swell);
  // copy and translate the 3rd line
  addVector = new PVector(-60, 30);
  for (PVector point : line2.anchorPoints) {
    line3.addPoint(point.copy().add(addVector));
  }
  line3.closeCurve();

  helperLineArr[1] = line2;
  helperLineArr[2] = line3;
  helperLineArr[3] = line1;
}

void noisySunHelperLines() {
  
  BezierLine line0 = new BezierLine();
  BezierLine line1 = new BezierLine();
  float x, y;
  float cx = width / 2;
  float cy = height / 2;
  int numPoints = 100;
  float radius = width/3.5;
  for (int i = 0; i < numPoints; i++) {
    x = cx + cos(TWO_PI/numPoints * i) * radius;
    y = cy + sin(TWO_PI/numPoints * i) * radius;
    line0.addPoint(new PVector(x,y));
  }
  line0.closeCurve();
  helperLineArr[0] = line0;
  
  radius = width/8;
  for (int i =0; i < numPoints; i++) {
    x = cx + cos(TWO_PI/numPoints * i) * radius;
    y = cy + sin(TWO_PI/numPoints * i) * radius;
    line1.addPoint(new PVector(x,y));
  }
  line1.closeCurve();
  helperLineArr[1] = line1;
}

void drawLines() {
  bigLine = new BezierLine(swell);  // not in all versions needed
  // bigLine = new BezierLine(0.3);  // not in all versions needed

  if (creationLinesVisible) {
    stroke(255, 0, 0);
    strokeWeight(2);
    for (int j = 0; j < helperLinesNo; j++) {
      helperLineArr[j].drawAll();
    }
    strokeWeight(strokeweight);
  }

  if (helperlinePointsVisible) {
    stroke(0, 0, 255);
    strokeWeight(2);
    for (int j = 0; j < helperLinesNo; j++) {
      for (PVector point : helperLineArr[j].anchorPoints) {
        circle(point.x, point.y, 5);
      }
      // circle(helperLineArr[j].anchorPoints.get(0).x, helperLineArr[j].anchorPoints.get(0).y, 5);
    }
    strokeWeight(strokeweight);
  }



  // calculate all the points on the helper lines
  PVector[][] pointsOnLine = new PVector[helperLinesNo][];

  for (int j = 0; j < helperLinesNo; j++) {
    pointsOnLine[j] = helperLineArr[j].getEquidistantPointArr(connectors);
  }

  if (helperlineIntervallsVisible) {
    stroke(255, 0, 0);
    strokeWeight(2);
    for (int i = 0; i < connectors; i++) {
      for (int j = 0; j < helperLinesNo; j++) {
        bigLine.addPoint(pointsOnLine[j][i]);
        circle(pointsOnLine[j][i].x, pointsOnLine[j][i].y, 3);
      }
    }
    strokeWeight(strokeweight);
  }


  stroke(0);
  for (int i = 0; i < connectors; i++) {

    if (straightLines) {
      // draw just straight lines
      for (int j = 0; j < helperLinesNo - 1; j++) {
        line(pointsOnLine[j][i].x, pointsOnLine[j][i].y, pointsOnLine[j+1][i].x, pointsOnLine[j+1][i].y);
      }
    } else {
      // create the big bezier curve
      for (int j = 0; j < helperLinesNo; j++) {
        bigLine.addPoint(pointsOnLine[j][i]);
      }
    }
  }
  if (closeHelperLines) {
    // in that case also close the large bezier-curve
    bigLine.closeCurve();
  }


  if (!straightLines) {
    // draw the big bezier curve
    if (multiColor) {
      stroke(0);
      bigLine.drawFromTo(1, bigLine.anchorPoints.size()/2);
      stroke(255, 0, 0);
      bigLine.drawFromTo(bigLine.anchorPoints.size()/2 + 1, bigLine.anchorPoints.size()-3);
    } else {
      // if (false) {
      if (closeHelperLines) {
        bigLine.drawAll();
      } else {
        bigLine.drawFromTo(1, bigLine.anchorPoints.size()-3);
      }
    }

    if (!animate) {
      println("length: ", (int) bigLine.getLength(5)/1000.0, "m");
    }
  }
}

void draw() {

  if (!animate || pauseAnimation) {
    return;
  }
  if (stillFrameCounter == 180 * 30) {
    // how long it should run (at 30 fps)
    exit();
  }

  if (!animationHelperLinesInitiated) {
    BezierLine line;

    // Initialize the top-level array with the number of helper lines
    animationPointVectors = new PVector[helperLinesNo][][];

    // initiate helper lines for each point on each of the helper lines
    for (int j = 0; j < helperLinesNo; j++) {

      // Initialize the second level array for each helper line based on number of points
      animationPointVectors[j] = new PVector[helperLinePoints[j]][];

      for (int i = 0; i < helperLinePoints[j]; i++) {
        line = createRndBezierLine(5);
        line.closeCurve();
        animationPointVectors[j][i] = line.getEquidistantPointArr(600 + (int)random(200));
      }
    }
    animationHelperLinesInitiated = true;
  }

  stillFrameCounter++;
  background(255);

  // create the helperLineArrs new
  BezierLine line;
  for (int j = 0; j < helperLinesNo; j++) {
    line = new BezierLine(swell);
    for (int i = 0; i < helperLinePoints[j]; i++) {
      if (j == 0) {
        line.addPoint(animationPointVectors[j][i][stillFrameCounter % animationPointVectors[j][i].length]);
      } else {
        line.addPoint(animationPointVectors[j][i][0]);
      }
    }
    if (closeHelperLines) {
      line.closeCurve();
    }
    helperLineArr[j] = line;
  }

  drawLines();
  // saveFrame("frames/#####.png");

  /*
  if (stillFrameCounter % 300 == 0) {
   // start a new object
   animationHelperLinesInitiated = false;
   }
   */
  // delay(10);
  println(stillFrameCounter);
}

void saveToFile() {
  // Save to a file
  //create a unique timestamp
  String timestamp = year() + "-" + month() + "-" + day() + "_" + hour() + "-" + minute() + "-" + second();

  if (straightLines) {
    beginRecord(SVG, sketchPath("output_" + timestamp + ".svg"));   // record it all to an SVG-File
    drawLines();
    endRecord(); // Beendet die SVG-Aufzeichnung
    println(sketchPath("output_" + timestamp + ".svg") + " written");
  } else {
    StringBuilder svgContent = new StringBuilder();

    // Header
    svgContent.append(createSVGHeader(width, height));
    if (bigLine.m_closedCurve) {
      svgContent.append(bigLine.toSVGPath(max_path_length_in_m * 1000, 0, 0)); // in mm (and if the format of your paper were the same as the canvas here in mm)
    } else {
      svgContent.append(bigLine.toSVGPath(max_path_length_in_m * 1000, 1, 1)); // in mm (and if the format of your paper were the same as the canvas here in mm)
      // Remove the first and the last segment!! Same as we draw it!
    }
    // Footer
    svgContent.append(createSVGFooter());

    // Write it to disc
    saveSVGToFile(svgContent.toString(), sketchPath("output_" + timestamp + ".svg"));
    println(sketchPath("output_" + timestamp + ".svg") + " written");
  }
}

void keyPressed () {
  if (key == '+') {
    connectors *= 1.1;
    println("connectors:", connectors);
  }
  if (key == '-') {
    connectors /= 1.1;
    println("connectors:", connectors);
  }
  if (key == 'm') {
    multiColor = !multiColor;
  }
  if (key == ' ') {
    pauseAnimation = !pauseAnimation;
  }
  if (key == 'p') {
    helperlinePointsVisible = !helperlinePointsVisible;
  }
  if (key == 't') {
    straightLines = !straightLines;
  }
  if (key == ENTER || key == RETURN) {
    if (animate) {
      animationHelperLinesInitiated = false;
    } else {
      createRndHelperLines();
    }
  }
  if (key == 'h') {
    creationLinesVisible = !creationLinesVisible;
  }
  if (key == 's') {
    saveToFile();
  }


  background(255);
  drawLines();
}
