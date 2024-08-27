import processing.svg.*;

BezierLine line1;
BezierLine line2;
BezierLine line3;
BezierLine bigLine;

int border = 100;
float strokeweight = 0.3;
boolean creationLinesVisible = false;

int connectors = 600;
int points1 = 7;
int points2 = 3;
int points3 = 5;

int version = 3;

int stillFrameCounter = 0;

void setup () {
  size(1410, 1000);
  background(255);
  strokeWeight(strokeweight);

  createRndLines();
  drawLines();
  // createRndLinesDbg();
  // drawLinesDbg();
}

void createRndLines() {
  line1 = new BezierLine();
  line2 = new BezierLine();
  line3 = new BezierLine();

  for (int i = 0; i < points1; i++) {
    line1.addPoint(new PVector(border + random(width - 2 * border), border + random(height - 2 * border)));
  }

  for (int i = 0; i < points2; i++) {
    line2.addPoint(new PVector(border + random(width - 2 * border), border + random(height - 2 * border)));
  }

  if (version == 3) {
    for (int i = 0; i < points3; i++) {
      line3.addPoint(new PVector(border + random(width - 2 * border), border + random(height - 2 * border)));
    }
  }


  // all lines have common points
  /*
  line2.addPoint(line1.points.get(0));
  line1.addPoint(line2.points.get(0));
  line3.addPoint(line1.points.get(0));
  */
  
  // all curves closed
  /*
  line1.closeCurve();
  line2.closeCurve();
  line3.closeCurve();
  */
  

  // test
  /*
  line1.addPoint(line1.points.get(0));
   line1.addPoint(line1.points.get(1));
   line2.addPoint(line2.points.get(0));
   line2.addPoint(line2.points.get(1));
   line3.addPoint(line3.points.get(0));
   line3.addPoint(line3.points.get(1));
   */
}

void drawLines() {
  bigLine = new BezierLine();  // not in all versions needed

  if (creationLinesVisible) {
    stroke(255, 0, 0);
    strokeWeight(2);
    line1.drawAll();
    line2.drawAll();
    if (version == 3) {
      line3.drawAll();
    }
    strokeWeight(strokeweight);
  }

   
  PVector[] pointsOnLine1 = null;
  PVector[] pointsOnLine2 = null;
  PVector[] pointsOnLine3 = null;

  if (version <= 3) {
    pointsOnLine1 = line1.getEquidistantPointArr(connectors); 
    pointsOnLine2 = line2.getEquidistantPointArr(connectors);
  }
  if (version == 3) {
    pointsOnLine3 = line3.getEquidistantPointArr(connectors);
  }

  stroke(0);
  for (int i = 0; i < connectors; i++) {

    if (version == 1) {
      // just straight lines, but optimized for pen plotter
      if ((i % 2) == 0) {
        line(pointsOnLine1[i].x, pointsOnLine1[i].y, pointsOnLine2[i].x, pointsOnLine2[i].y);
      } else {
        line(pointsOnLine2[i].x, pointsOnLine2[i].y, pointsOnLine1[i].x, pointsOnLine1[i].y);
      }
    }
    if (version >= 2) {
      // connect the points to a new snaking bezier curve
      bigLine.addPoint(pointsOnLine1[i]);
      bigLine.addPoint(pointsOnLine2[i]);
    }
    if (version == 3) {
      bigLine.addPoint(pointsOnLine3[i]);
    }
    
  }
    
  if (version >= 2) {
    /* multi colored
    stroke(0);
    bigLine.drawFromTo(1, bigLine.points.size()/2);
    stroke(255,0,0);
    bigLine.drawFromTo(bigLine.points.size()/2 + 1, bigLine.points.size()-3);
    */
    
    bigLine.drawFromTo(1, bigLine.points.size()-3);
    // bigLine.closeCurve();
    // bigLine.drawAll();
    println("length: ", (int) bigLine.getLength(5)/1000.0, "m");
  }
}

void draw() {
  // making a movie
  // grab one point on line 1 and jiggle it arund a bit
  stillFrameCounter++;
  line1.movePoint(0, new PVector(-5 * sin((float)stillFrameCounter/34), 5 * cos((float)stillFrameCounter/34)));
  line1.movePoint(1, new PVector(4 * sin((float)stillFrameCounter/40), 4 * cos((float)stillFrameCounter/40)));
  line1.movePoint(2, new PVector(-3 * sin((float)stillFrameCounter/30), -3 * cos((float)stillFrameCounter/30)));
  line1.movePoint(3, new PVector(4 * sin((float)stillFrameCounter/60), 4 * cos((float)stillFrameCounter/60)));
  line1.movePoint(4, new PVector(-2 * sin((float)stillFrameCounter/46), 2 * cos((float)stillFrameCounter/46)));
  line1.movePoint(5, new PVector(3 * sin((float)stillFrameCounter/66), -3 * cos((float)stillFrameCounter/66)));

  line2.movePoint(0, new PVector(5 * sin((float)stillFrameCounter/34), 5 * cos((float)stillFrameCounter/34)));
  line2.movePoint(1, new PVector(-4 * sin((float)stillFrameCounter/40), -4 * cos((float)stillFrameCounter/40)));
  line2.movePoint(2, new PVector(3 * sin((float)stillFrameCounter/36), 3 * cos((float)stillFrameCounter/36)));
  background(255);
  drawLines();
  // saveFrame("frames/#####.png");
  // delay(10);
}

void mousePressed() {
  if (mouseButton == LEFT) {
    // make a new one
    background(255);
    createRndLines();
    drawLines();
    // createRndLinesDbg();
    // drawLinesDbg();
  }

  if (mouseButton == RIGHT) {
    // Save to a file
    //create a unique timestamp
    String timestamp = year() + "-" + month() + "-" + day() + "_" + hour() + "-" + minute() + "-" + second();

    if (version == 1) {
      beginRecord(SVG, sketchPath("output_" + timestamp + ".svg"));   // record it all to an SVG-File
      drawLines();
      endRecord(); // Beendet die SVG-Aufzeichnung
      println(sketchPath("output_" + timestamp + ".svg") + " written");
    }
    if (version >= 2) {
      StringBuilder svgContent = new StringBuilder();

      // Header
      svgContent.append(createSVGHeader(width, height));
      svgContent.append(bigLine.toSVGPath(500000, 1, 1)); // in mm (and if the format of your paper were the same as the canvas here in mm)
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
  background(255);
  drawLines();
}
