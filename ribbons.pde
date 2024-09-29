import processing.svg.*;

BezierLine bigLine;

int border = 100;  // which part of the canvas should not be used to decrease the chance that lines go outside the canvas
float strokeweight = 0.3;
boolean creationLinesVisible = false;

// all about making movies and animations (experimental)
boolean makeMovie = false;
boolean movieHelperLinesInitiated = false;
PVector[][][] moviePointVectors;

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

int[] helperLinePoints = {5, 4, 2};

// other samples that work well
// int[] helperLinePoints = {2,4,5};
// int[] helperLinePoints = {2,3};

int connectors = 1000;  // number of perceived lines, roughly (can be changed while the program runs with "+" or "-")

// draw straight lines instead of a bezier curve; looks completely different
boolean straightLines = false;

// close each helper line onto itself
boolean closeHelperLines = false;

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

  if (!makeMovie) {
    createRndHelperLines();
    drawLines();
  }
}

BezierLine createRndBezierLine(int numPoints) {
  // create a bezierLIne with a number of random points on the canvas
  BezierLine line = new BezierLine();
  for (int i = 0; i < numPoints; i++) {
    line.addPoint(new PVector(border + random(width - 2 * border), border + random(height - 2 * border)));
  }
  if (closeHelperLines && numPoints > 2) {
    line.closeCurve();
  }
  return line;
}

void createRndHelperLines() {
  // create a number of random bezier lines of given length
  for (int j = 0; j < helperLinesNo; j++) {
    helperLineArr[j] = createRndBezierLine(helperLinePoints[j]);
  }
}

void drawLines() {
  bigLine = new BezierLine();  // not in all versions needed

  if (creationLinesVisible) {
    stroke(255, 0, 0);
    strokeWeight(2);
    for (int j = 0; j < helperLinesNo; j++) {
      helperLineArr[j].drawAll();
    }
    strokeWeight(strokeweight);
  }

  // calculate all the points on the helper lines
  PVector[][] pointsOnLine = new PVector[helperLinesNo][];

  for (int j = 0; j < helperLinesNo; j++) {
    pointsOnLine[j] = helperLineArr[j].getEquidistantPointArr(connectors);
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


  if (!straightLines) {
    // draw the big bezier curve
    if (multiColor) {
      stroke(0);
      bigLine.drawFromTo(1, bigLine.points.size()/2);
      stroke(255, 0, 0);
      bigLine.drawFromTo(bigLine.points.size()/2 + 1, bigLine.points.size()-3);
    } else {
      bigLine.drawFromTo(1, bigLine.points.size()-3);
    }

    if (!makeMovie) {
      println("length: ", (int) bigLine.getLength(5)/1000.0, "m");
    }
  }
}

void draw() {

  if (!makeMovie) {
    return;
  }
  if (stillFrameCounter == 180 * 30) {
    // how long it should run (at 30 fps)
    exit();
  }

  if (!movieHelperLinesInitiated) {
    BezierLine line;

    // Initialize the top-level array with the number of helper lines
    moviePointVectors = new PVector[helperLinesNo][][];

    // initiate helper lines for each point on each of the helper lines
    for (int j = 0; j < helperLinesNo; j++) {

      // Initialize the second level array for each helper line based on number of points
      moviePointVectors[j] = new PVector[helperLinePoints[j]][];

      for (int i = 0; i < helperLinePoints[j]; i++) {
        line = createRndBezierLine(5);
        line.closeCurve();
        moviePointVectors[j][i] = line.getEquidistantPointArr(600 + (int)random(200));
      }
    }
    movieHelperLinesInitiated = true;
  }

  stillFrameCounter++;
  background(255);

  // create the helperLineArrs new
  BezierLine line;
  for (int j = 0; j < helperLinesNo; j++) {
    line = new BezierLine();
    for (int i = 0; i < helperLinePoints[j]; i++) {
      line.addPoint(moviePointVectors[j][i][stillFrameCounter % moviePointVectors[j][i].length]);
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
   movieHelperLinesInitiated = false;
   }
   */
  // delay(10);
  println(stillFrameCounter);
}

void mousePressed() {
  if (mouseButton == LEFT) {
    // make a new one
    background(255);
    
    if (makeMovie) {
      movieHelperLinesInitiated = false;
    } else {
      createRndHelperLines();
      drawLines();
    }
  }

  if (mouseButton == RIGHT) {
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
      svgContent.append(bigLine.toSVGPath(max_path_length_in_m * 1000, 1, 1)); // in mm (and if the format of your paper were the same as the canvas here in mm)
      // Remove the first and the last segment!! Same as we draw it!!
      // Footer
      svgContent.append(createSVGFooter());

      // Write it to disc
      saveSVGToFile(svgContent.toString(), sketchPath("output_" + timestamp + ".svg"));
      println(sketchPath("output_" + timestamp + ".svg") + " written");
    }
  }

  if (mouseButton == CENTER) {
    creationLinesVisible = !creationLinesVisible;
    background(255);
    drawLines();
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

  background(255);
  drawLines();
}
