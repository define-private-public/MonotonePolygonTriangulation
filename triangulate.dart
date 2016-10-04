
library triangulate;

import 'dart:html';
import 'stack.dart';
import 'merge-sort.dart';
import 'geometry.dart';


/*== Global State Variables ==*/
// yes, yes... I know they are a bad practice to use, but they make this demo easier to write
bool stepThroughMode = false;


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





// Will toggle on/off "step through" mode
void onStepThroughToggled(var _) {
  // Toggle step through mode
  stepThroughMode = !stepThroughMode;

  // Alter the HTML & CSS of the button
  stepThroughToggle.text = stepThroughMode ? stepThroughToggleOnText : stepThroughToggleOffText;
  stepThroughToggle.classes.toggle('toggle-on', stepThroughMode);
}



void main() {
  // Attach event handlers
  stepThroughToggle.onClick.listen(onStepThroughToggled);

  // Fill the background
  canvasCtx..fillStyle = backgroundClr
           ..fillRect(0, 0, canvas.width, canvas.height);

  drawLineSegment(canvasCtx, new LineSegment(new Point(5, 5), new Point (150, 50)), monotoneLineClr);

  List<Point> polygon = [
    new Point(10,10),
    new Point(50,10),
    new Point(50,50),
    new Point(10,45),
  ];
  drawPolygon(canvasCtx, polygon, monotoneLineClr);
}

