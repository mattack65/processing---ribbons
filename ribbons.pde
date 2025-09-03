import processing.svg.*;

// added just for the coloring of areas
import org.locationtech.jts.geom.*;
import org.locationtech.jts.operation.polygonize.Polygonizer;
import org.locationtech.jts.operation.union.UnaryUnionOp;

import java.util.Collection;
import java.util.ArrayList;

// the one big line that we construct and draw
BezierLine bigLine;

int border = 50;  // which part of the canvas should not be used to decrease the chance that lines go outside the canvas
float strokeweight = 0.3;
boolean creationLinesVisible = false;
boolean helperlinePointsVisible = false;

// all about making movies and animations (experimental)
boolean animate = false;
boolean animationHelperLinesInitiated = false;
boolean pauseAnimation = false;
PVector[][][] animationPointVectors;
boolean helperlineIntervallsVisible = false;

// for coloring or hatching some areas
ArrayList<Polygon> polygons;
ArrayList<PVector> segPointsAdaptive;
// how we sample the bezier line into segements for polygonization
float angleThresholdDeg = 4.0;
float tStep = 0.01;
float maxLength = 10.0;
ArrayList<Integer> hatchColors = new ArrayList<Integer>();
boolean hatchAreas = true;
float polygonMinArea = 50.0;
float polygonMaxArea = 5000.0;

// for contour-filling the polygons
ArrayList<FillPolygon> contourFillPolygons;
ArrayList<Geometry> polygonsOrdered;
ArrayList<Geometry> strokeLines;

float hatchLineDistanceScreen = 0.3;  // how many mm apart, assuming the size of the canvas were in mm
float hatchLineDistanceSVG = 0.5;  // how many mm apart, assuming the size of the canvas were in mm
// for floadfilling
float firstOffsetScreen = 0.2;  // how many mm apart, assuming the size of the canvas were in mm
float stepOffsetScreen = 0.2;  // how many mm apart, assuming the size of the canvas were in mm

float firstOffsetSVG = 0.8;  // how many mm apart, assuming the size of the canvas were in mm (A1: 0.5; A2: 0.8; A3: 1.0)
float stepOffsetSVG = 0.6;  // how many mm apart, assuming the size of the canvas were in mm (A1: 0.4; A2: 0.6; A3: 0.8)

// TODO: - use a color palette of a few matching colors
//       - make the chosen color not random, but depending on ... distance from left border, distance from center, diagonal, ... 
//       - improve the choice of which polygon to color, so that it looks less random and more like a checkerboard

color[] stroke_color_group1 = { 
  color(255, 102, 102),  // Soft pinkish-red
  color(255, 51, 51),    // Bright red with a hint of pink
  color(255, 128, 0),    // Vibrant orange
  color(255, 69, 0),     // Deep orange-red
  color(255, 0, 0),      // Pure bright red
  color(204, 0, 0),      // Deep red
  color(153, 0, 51),     // Dark crimson red
  color(128, 0, 0)       // Dark, muted maroon
};

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

// int[] helperLinePoints = {6, 3};

// other samples that work well
// int[] helperLinePoints = {4,4,4,4};
// int[] helperLinePoints = {4, 3, 2};
int[] helperLinePoints = {4, 4};

int connectors = 100;  // number of perceived lines, roughly (can be changed while the program runs with "+" or "-")

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

  // pureRndHelperLines();
  // translatedRotatedHelperLines(); // there must be exactly two helper lines defined
  // wernersRndHelperLines(); // there must be exactly four helper lines defined
  noisySunHelperLines();  // needs two helper lines
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
  float angleRad = radians(10);  // your rotation angle in degrees

  // Define the center of rotation
  PVector centerOfRotation = new PVector(width/2, height/2);  // (cx, cy) is the point around which you want to rotate

  for (PVector point : line1.anchorPoints) {
    // Copy the point, rotate it around (0,0), then translate it
    PVector rotatedPoint = point.copy()
      .sub(centerOfRotation)  // Step 1: Move to origin
      .rotate(angleRad)       // Step 2: Rotate
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
  
  BezierLine line0 = new BezierLine(swell);
  BezierLine line1 = new BezierLine(swell);
  float x, y;
  float cx = width / 2;
  float cy = height / 2;
  int numPoints = 70;
  float radius = width/3.5;
  float stretch;
  for (int i = 0; i < numPoints; i++) {
    stretch = radius + random(width/35);
    x = cx + cos(TWO_PI/numPoints * i) * stretch;
    y = cy + sin(TWO_PI/numPoints * i) * stretch;
    line0.addPoint(new PVector(x,y));
  }
  line0.closeCurve();
  helperLineArr[0] = line0;
  
  numPoints = 50;
  radius = width/8;
  for (int i =0; i < numPoints; i++) {
    stretch = radius + random(width/50);
    x = cx + cos(TWO_PI/numPoints * i) * stretch;
    y = cy + sin(TWO_PI/numPoints * i) * stretch;
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

    // hatching
    if (hatchAreas) {
      // find the polygons
      polygonizePolyline();
      
      // color every second one
      DrawHatchedPolygons(null);
    }
  }
}

void DrawHatchedPolygons(StringBuilder svgOut) {
  if (svgOut == null) {
    // Just draw to screen
    for (int i = 0; i < polygons.size(); i++) {
      // if (i % 2 == 0) {  // fill 50% of all polygons
      if (i % 4 != 0) {  // fill 3/4 of all polygons
        color strokeCol = hatchColors.get(i / 2);
        stroke(strokeCol);
        // HatchJTSPolygon(polygons.get(i), null);
        OffsetFillJTSPolygon(polygons.get(i), null);
      }
    }
  } else {
    // SVG output with grouping by color
    HashMap<Integer, StringBuilder> colorGroups = new HashMap<Integer, StringBuilder>();

    // First collect paths grouped by color
    for (int i = 0; i < polygons.size(); i++) {
      // if (i % 2 == 0) {  // fill 50% of all polygons
      if (i % 4 != 0) {  // fill 3/4 of all polygons
        color strokeCol = hatchColors.get(i / 2);  // not entirely correct (too many) but works anyway
        StringBuilder groupBuilder = colorGroups.get(strokeCol);
        if (groupBuilder == null) {
          groupBuilder = new StringBuilder();
          colorGroups.put(strokeCol, groupBuilder);
        }

        StringBuilder hatchPath = new StringBuilder();
        /*
        HatchJTSPolygon(polygons.get(i), hatchPath);
        groupBuilder.append(String.format(
          "<path d=\"%s\" />\n",
          hatchPath.toString().trim()          
        ));
        */
        OffsetFillJTSPolygon(polygons.get(i), hatchPath);
        groupBuilder.append(hatchPath.toString());
      }
    }

    // Then emit each group as its own Inkscape layer
    int layerNum = 1;
    for (color col : colorGroups.keySet()) {
      String hexColor = String.format("#%06X", (0xFFFFFF & col));
      svgOut.append(String.format(
        "<g inkscape:groupmode=\"layer\" inkscape:label=\"%d_Hatch %s\" stroke=\"%s\" stroke-width=\"0.3\" fill=\"none\">\n",
        layerNum++, hexColor, hexColor));      
      svgOut.append(colorGroups.get(col).toString());
      svgOut.append("</g>\n");
    }
  }
}

  

void HatchJTSPolygon(Geometry geom, StringBuilder svgOut) {
  ArrayList<PVector> pointList;
  if (geom instanceof Polygon) {
    Polygon poly = (Polygon) geom;
    pointList = convertJTSPolygonToPVectorList(poly);
    // get the width and height to find which direction to draw best
    Envelope envelope = poly.getEnvelopeInternal();
    float w = (float) (envelope.getMaxX() - envelope.getMinX());
    float h = (float) (envelope.getMaxY() - envelope.getMinY());
    float direction = 0;
    if (w < h) {
      direction = 90;
    }
    Hatch(pointList, direction, (svgOut == null ? hatchLineDistanceScreen : hatchLineDistanceSVG), 0.01, svgOut);
  } else if (geom instanceof GeometryCollection) {
    for (int i = 0; i < geom.getNumGeometries(); i++) {
      HatchJTSPolygon(geom.getGeometryN(i), svgOut);
    }
  }
}

void OffsetFillJTSPolygon(Geometry geom, StringBuilder svgOut) {
  if (geom instanceof Polygon) {
    Polygon poly = (Polygon) geom;
  
    contourFillPolygons = new ArrayList<FillPolygon>();

    BufferParameters params = new BufferParameters();
    params.setQuadrantSegments(16);
    contourFill(poly, (svgOut == null ? firstOffsetScreen : firstOffsetSVG), (svgOut == null ? stepOffsetScreen: stepOffsetSVG), params, true, contourFillPolygons);
    polygonsOrdered = buildFillPaths(contourFillPolygons, true, 5 * (svgOut == null ? stepOffsetScreen: stepOffsetSVG));
    // polygonsOrdered = buildFillPaths(contourFillPolygons, false, 5 * (svgOut == null ? stepOffsetScreen: stepOffsetSVG));  // polygons not conected, lots of pen-up
    if (svgOut != null) {
      svgOut.append(generateSVGPaths(polygonsOrdered));
    } else {
      strokeWeight(1); // to make it look a bit better on screen
      for (Geometry g : polygonsOrdered) {
        drawGeometry(g);
      }
      strokeWeight(strokeweight);
    }
  } else if (geom instanceof GeometryCollection) {
    for (int i = 0; i < geom.getNumGeometries(); i++) {
      OffsetFillJTSPolygon(geom.getGeometryN(i), svgOut); 
    }
  }  
}

ArrayList<PVector> convertJTSPolygonToPVectorList(Polygon polygon) {
  // helper function to turn a JTS-Polygon back to a PVector Array
  ArrayList<PVector> pointList = new ArrayList<PVector>();
  
  // Get the coordinates of the exterior ring of the polygon
  Coordinate[] coords = polygon.getExteriorRing().getCoordinates();
  
  // Iterate through the coordinates (excluding the last one, which is a duplicate for closing the polygon)
  for (int i = 0; i < coords.length - 1; i++) {
    pointList.add(new PVector((float) coords[i].x, (float) coords[i].y));
  }
  
  return pointList;
}

void updateHatchColors() {
  // println("Updating hatch colors...");
  hatchColors.clear();
  int noOfColors = polygons.size()/2 + 1;
  for (int i = 0; i < noOfColors; i++) {
    hatchColors.add(stroke_color_group1[(int)random(8)]);
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
    
    // 
    if (hatchAreas) {
      // draw the hatched polygons (without outlines)
      StringBuilder hatchLines = new StringBuilder();
      DrawHatchedPolygons(hatchLines);
      svgContent.append(hatchLines);
    }
    
    
    // Footer
    svgContent.append(createSVGFooter());

    // Write it to disc
    saveSVGToFile(svgContent.toString(), sketchPath("output_" + timestamp + ".svg"));
    println(sketchPath("output_" + timestamp + ".svg") + " written");
  }
}

/**
 * Converts a Bézier curve (approximated by an adaptively sampled polyline) into a list of polygons
 * by detecting all closed regions formed by self-intersections.
 *
 * The method:
 * - Generates adaptively sampled points from the Bézier curve using curvature and distance constraints.
 * - Converts these points into line segments (as JTS LineStrings).
 * - Applies unary union (noding) to split all intersections into explicit vertices.
 * - Uses JTS Polygonizer to identify all closed loops formed by the resulting graph of line segments.
 * - Filters polygons by area to remove tiny or sliver artifacts.
 *
 * The resulting polygons can be used for hatching, filling, or other graphical processing.
 *
 * This method relies on the current state of the global `bigLine` and stores the resulting
 * polygons in a global list (`polygons`) for downstream use.
 *
 * Console output provides diagnostics on:
 * - Number of adaptive points
 * - Total polygons found
 * - Polygons kept after filtering
 */

void polygonizePolyline() {
  // in case we want to hatch certain areas, we have to identify these areas as polygons
  GeometryFactory gf = new GeometryFactory();
  ArrayList<Geometry> segments = new ArrayList<Geometry>();
  
  segPointsAdaptive = bigLine.getCurvatureAdaptivePoints(angleThresholdDeg, tStep, maxLength);
  println("Adaptive points: " + segPointsAdaptive.size());
  
  int count = segPointsAdaptive.size();
  int limit = bigLine.m_closedCurve ? count : count - 1;
  
  for (int i = 0; i < limit; i++) {
    PVector p1 = segPointsAdaptive.get(i);
    PVector p2 = segPointsAdaptive.get((i + 1) % count);  // wraps around if closed
  
    Coordinate[] segCoords = new Coordinate[] {
      new Coordinate(p1.x, p1.y),
      new Coordinate(p2.x, p2.y)
    };
    LineString seg = gf.createLineString(segCoords);
    segments.add(seg);
  }

  // Node segments (split at intersections)
  GeometryCollection gc = gf.createGeometryCollection(segments.toArray(new Geometry[0]));
  Geometry noded = UnaryUnionOp.union(gc);

  // Polygonize
  Polygonizer polygonizer = new Polygonizer();
  polygonizer.add(noded);

  Collection<Geometry> jtsPolygons = polygonizer.getPolygons();
  println("Total polygons found: " + jtsPolygons.size());

  polygons = new ArrayList<Polygon>();
  for (Geometry g : jtsPolygons) {
    if (g instanceof Polygon) {
      Polygon p = (Polygon) g;
      double pArea = p.getArea();
      // println(pArea);
      if (( pArea > polygonMinArea) && (pArea < polygonMaxArea)) {
        polygons.add(p);
      }
    }
  }
  
  // create the colors for the polygons
  updateHatchColors();

  println("Polygons kept after filtering: " + polygons.size());
}


void keyPressed () {
  boolean redraw = false;
  if (key == '+') {
    connectors *= 1.1;
    println("connectors:", connectors);
    redraw = true;
  }
  if (key == '-') {
    connectors /= 1.1;
    println("connectors:", connectors);
    redraw = true;
  }
  if (key == 'm') {
    multiColor = !multiColor;
    redraw = true;
  }
  if (key == ' ') {
    pauseAnimation = !pauseAnimation;
  }
  if (key == 'p') {
    helperlinePointsVisible = !helperlinePointsVisible;
    redraw = true;
  }
  if (key == 't') {
    straightLines = !straightLines;
    redraw = true;
  }
  if (key == ENTER || key == RETURN) {
    if (animate) {
      animationHelperLinesInitiated = false;
    } else {
      createRndHelperLines();
    }
    redraw = true;
  }
  if (key == 'h') {
    creationLinesVisible = !creationLinesVisible;
    redraw = true;
  }
  if (key == 'r') {
    updateHatchColors();
    redraw = true;
  }
  if (key == 's') {
    saveToFile();
  }

  if (redraw) {
    background(255);
    drawLines();
  }
}
