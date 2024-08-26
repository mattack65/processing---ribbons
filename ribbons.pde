import processing.svg.*;

BezierLine line1;
BezierLine line2;
BezierLine line3;
BezierLine bigLine;

int border = 100;
float strokeweight = 0.2;
boolean creationLinesVisible = false;

int connectors = 1400;
int points1 = 2;
int points2 = 7;
int points3 = 3;

int version = 3;

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
}

void drawLines() {
  PVector p1 = new PVector(0, 0);
  PVector p2 = new PVector(0, 0);
  PVector p3 = new PVector(0, 0);

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

  stroke(0, 0, 0);
  for (int i = 0; i < connectors; i++) {
    p1 = line1.getPointAtPct(float(i)/(connectors - 1));
    p2 = line2.getPointAtPct(float(i)/(connectors - 1));

    if (version == 3) {
      p3 = line3.getPointAtPct(float(i)/(connectors - 1));
    }

    if (version == 1) {
      // just lines, but optimized for pen plotter
      if ((i % 2) == 0) {
        line(p1.x, p1.y, p2.x, p2.y);
      } else {
        line(p2.x, p2.y, p1.x, p1.y);
      }
    }

    if (version == 2) {
      // connect the points to a new snaking bezier curve
      bigLine.addPoint(p1);
      bigLine.addPoint(p2);
    }

    if (version == 3) {
      bigLine.addPoint(p1);
      bigLine.addPoint(p2);
      bigLine.addPoint(p3);
    }
  }

  if (version == 2 || version == 3) {
    bigLine.drawFromTo(1, bigLine.points.size()-3);
    println("length: ", (int) bigLine.getLenght(0, bigLine.points.size(), 5)/1000.0, "m");
  }
}

void draw() {
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
    if ((version ==2) || (version ==3)) {
      StringBuilder svgContent = new StringBuilder();

      // Header
      svgContent.append(createSVGHeader(width, height));
      svgContent.append(bigLine.toSVGPathsMaxLengthPerPath(1000000, 1, 1)); // in mm (and if the format of your paper were the same as the canvas here in mm)
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
