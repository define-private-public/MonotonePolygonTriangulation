
library triangulate;

import 'dart:html';
import 'stack.dart';
import 'merge-sort.dart';
import 'geometry.dart';


/*== Global State Variables ==*/
// yes, yes... I know they are a bad practice to use, but they make this demo easier to write
bool stepThroughMode = false;
bool triangulating = false;
List<Point> masterPolygon = [];
List<Point> lowerChain = [];
List<Point> upperChain = [];


/*== Functions ==*/
// Makes a nice RGB value
String rgb(int r, int g, int b) =>
  'rgb($r, $g, $b)';


/*== Some constants ==*/
// For drawing
String backgroundClr = rgb(0, 46, 76);
String monotoneLineClr = rgb(153, 214, 255);
String nonMonotoneLineClr = rgb(255, 51, 51);
String upperChainPointClr = rgb(0, 0xFF, 0);
String lowerChainPointClr = rgb(0, 0, 0xFF);
String reflexChainClr = rgb(0xFF, 0, 0);
String currentLineClr = rgb(0xFF, 0x00, 0x00);
const num lineWidth = 1.5;

// Algorithm Case colors
String caseInactiveClr = rgb(0xFF, 0xFF, 0xFF);
String caseActiveClr = rgb(153, 214, 255);

// Text
const String stepThroughToggleOffText = 'Step Through [Off]';
const String stepThroughToggleOnText = 'Step Through [On]';


// Interactive HTML section
CanvasElement canvas = querySelector('#polygon-canvas');
CanvasRenderingContext2D canvasCtx = canvas.context2D;
ButtonElement triangulateButton = querySelector('#triangulate');
ButtonElement stepThroughToggle = querySelector('#step-through-toggle');
ButtonElement stepButton = querySelector('#step');


/*== TODO Info section ==*/

// Algorithm HTML section
DivElement case1Div = querySelector('#case-one');
DivElement case2aDiv = querySelector('#case-two-a');
DivElement case2bDiv = querySelector('#case-two-b');


/*== Functions ==*/

// Draws a Line Segment
//   ctx -- a CanvasRenderingContext2D
//   l -- a LineSegment to draw
//   clr -- a color to give the line
void drawLineSegment(CanvasRenderingContext2D ctx, LineSegment l, String clr) {
  ctx..beginPath()
     ..lineWidth = lineWidth
     ..strokeStyle = clr
     ..moveTo(l.a.x, l.a.y)
     ..lineTo(l.b.x, l.b.y)
     ..closePath()
     ..stroke();
}


// Draws a Polygon (collection of Points), no fill (only outline)
//   ctx -- a CanvasRenderingContext2D
//   polygon -- a List of Points that represent the Polygon to draw
//   clr -- a color to draw the lines
void drawPolygon(CanvasRenderingContext2D ctx, List<Point> polygon, String clr) {
  // Need at least two points
  if (polygon.length < 2)
    return;

  // Draw the first point
  Point first = polygon.first;
  ctx..beginPath()
     ..lineWidth = lineWidth
     ..strokeStyle = clr
     ..moveTo(first.x, first.y);

  // Draw the rest of the segments
  for (Point p in polygon.skip(1))
    ctx.lineTo(p.x, p.y);

  // Finish up the line
  ctx..closePath()
     ..stroke();
}


// The main drawing function of the program
void drawScene() {
  // TODO check for monotonicity

  // Fill the background
  canvasCtx..fillStyle = backgroundClr
           ..fillRect(0, 0, canvas.width, canvas.height);

  // Draw the master polygon
  drawPolygon(canvasCtx, masterPolygon, monotoneLineClr);
}


/*== Event Handlers ==*/
// For the stepThrough toggle button, Will toggle on/off "step through" mode
void onStepThroughToggled(var _) {
  // Toggle step through mode
  stepThroughMode = !stepThroughMode;

  // Alter the HTML & CSS of the button
  stepThroughToggle.text = stepThroughMode ? stepThroughToggleOnText : stepThroughToggleOffText;
  stepThroughToggle.classes.toggle('toggle-on', stepThroughMode);
}


// For the Canvas, Adds a Point to the Polygon 
void onLeftClick(MouseEvent e) {
  // On Left press, add a Point
  if ((e.button == 0) && !triangulating)
    masterPolygon.add(new Point(e.offset.x, e.offset.y));
  
  // redraw the scene
  drawScene();
}


// For the Canvas, it shows a preview point
void onMouseMove(MouseEvent e) {
  // If in edit more, show a preview of a new point
  if (!triangulating) {
    masterPolygon.add(new Point(e.offset.x, e.offset.y));

    // redraw the scene
    drawScene();

    // remove that point now
    masterPolygon.removeLast();
  }
}


// For the Canvas, if the mouse was moved out, it will redraw the scene
// This is so we don't have any left-over preview lines
void onMouseOut(var _) =>
  drawScene();


// For the Canvas, if there is a Right-Click, it will remove a Point from the polygon
void onRightClick(MouseEvent e) {
  // Need to prevent the context menu poping up
  e.preventDefault();

  // Only remove when not triangulating
  if (!triangulating && (masterPolygon.length != 0)) {
    masterPolygon.removeLast();
    drawScene();
  }
}


void main() {
  // Some testing code for the chains
  masterPolygon.add(new Point(180, 200));
  masterPolygon.add(new Point(200, 170));
  masterPolygon.add(new Point(250, 150));
  masterPolygon.add(new Point(310, 190));
  masterPolygon.add(new Point(260, 250));
  masterPolygon.add(new Point(220, 240));

  getUpperAndLowerChains(masterPolygon, upperChain, lowerChain);
  print('UC: ' + upperChain.toString());
  print('LC: ' + lowerChain.toString());

  // Attach event handlers for the control buttons
  stepThroughToggle.onClick.listen(onStepThroughToggled);

  // Attach event handlers for the Canvas
  canvas.onClick.listen(onLeftClick);
  canvas.onContextMenu.listen(onRightClick);
  canvas.onMouseMove.listen(onMouseMove);
  canvas.onMouseOut.listen(onMouseOut);

  // Draw the scene
  drawScene();
}

