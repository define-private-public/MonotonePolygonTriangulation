
library triangulate;

import 'dart:html';
import 'dart:math';
import 'stack.dart';
import 'merge-sort.dart';
import 'geometry.dart';


/*== Return values ==*/
// TODO document
enum AlgorithmCase {
  Invalid,
  One,
  TwoA,
  TwoB
}


/*== Global State Variables ==*/
// yes, yes... I know they are a bad practice to use, but they make this demo easier to write
bool stepThroughMode = false;
bool triangulating = false;
List<Point> masterPolygon = [];
int stepNumber = -1;


/*== Functions ==*/
// Makes a nice RGB value
String rgb(int r, int g, int b) =>
  'rgb($r, $g, $b)';


/*== Some constants ==*/
// For drawing
String backgroundClr = rgb(0, 46, 76);
String monotoneLineClr = rgb(153, 214, 255);
String nonMonotoneLineClr = rgb(255, 51, 51);
String upperChainPointClr = rgb(255, 89, 255);
String lowerChainPointClr = rgb(35, 255, 39);
String reflexChainClr = rgb(220, 0, 0);
String currentLineClr = rgb(220, 0, 0);
const num lineWidth = 1.5;

// Algorithm Case colors
String caseInactiveClr = rgb(0xFF, 0xFF, 0xFF);
String caseActiveClr = rgb(153, 214, 255);

// Text
const String stepThroughToggleOffText = 'Step Through [Off]';
const String stepThroughToggleOnText = 'Step Through [On]';
const String triangulateToggleOffText = 'Triangulate [Off]';
const String triangulateToggleOnText = 'Triangulate [On]';
const String stepButtonText = 'Step';
const String stepButtonStartText = 'Start Stepping';
const String stepButtonDoneText = 'Done Stepping';


// Interactive HTML section
CanvasElement canvas = querySelector('#polygon-canvas');
CanvasRenderingContext2D canvasCtx = canvas.context2D;
ButtonElement triangulateToggle = querySelector('#triangulate');
ButtonElement stepThroughToggle = querySelector('#step-through-toggle');
ButtonElement stepButton = querySelector('#step');


/*== TODO Info section ==*/

// Algorithm HTML section
DivElement case1Div = querySelector('#case-one');
DivElement case2aDiv = querySelector('#case-two-a');
DivElement case2bDiv = querySelector('#case-two-b');


/*== Functions ==*/

// Turns on/off the Triangulate button depending upon the state of the polygon
void checkEnableTriangulateToggle() {
  // Need at least four points to triangulate
  triangulateToggle.disabled = (masterPolygon.length <= 3);

  // TODO check for monotinicy as well?
}


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


// Draws a single Point
// TODO document better
void drawPoint(CanvasRenderingContext2D ctx, Point p, String clr, [bool fill=false, num radius=7]) {
  // Make sure we've got something to draw
  if (radius < 0)
    return;

  if (fill) {
    // Fill draw
    ctx..beginPath()
       ..fillStyle = clr 
       ..arc(p.x, p.y, radius, 0, PI * 2)
       ..closePath()
       ..fill();
  } else {
    // Outline draw
    ctx..beginPath()
       ..strokeStyle = clr 
       ..lineWidth = (lineWidth * 1.5)
       ..arc(p.x, p.y, radius, 0, PI * 2)
       ..closePath()
       ..stroke();
  }

}


// The main drawing function of the program
// It has some non-drawing logic though...
void drawScene() {
  // Fill the background
  canvasCtx..fillStyle = backgroundClr
           ..fillRect(0, 0, canvas.width, canvas.height);

  String polygonClr = monotoneLineClr;

  // Get the chains, Have to do a swap becuase Canvas is an upside down cartesian graph
  List<Point> upperChain = [], lowerChain = [];
  bool gotChains = getUpperAndLowerChains(masterPolygon, lowerChain, upperChain);

  if (gotChains) {
    // Check if polygon is monotone
    bool isMonotone = isChainXMonotone(upperChain) && isChainXMonotone(lowerChain);

    // Pop off the first and last parts of the lower chain (no duplicates)
    // It doesn't really matter, as long as we don't have dubs
    lowerChain.removeAt(0);
    lowerChain.removeLast();

    polygonClr = isMonotone ? monotoneLineClr : nonMonotoneLineClr;
  }

  // Draw the master polygon
  drawPolygon(canvasCtx, masterPolygon, polygonClr);

  // If triangulating, draw the diagonals
  if (triangulating) {
    // Get them
    Stack<Point> rc = new Stack<Point>();
    List<LineSegment> diagonals = getDiagonals(masterPolygon, stepNumber, rc);

    // Draw the lines
    for (LineSegment l in diagonals)
      drawLineSegment(canvasCtx, l, monotoneLineClr); 

    if (stepThroughMode) {
      // Draw the reflex Chain
      for (Point p in rc.getIter())
        drawPoint(canvasCtx, p, reflexChainClr, true);

      // Draw the Upper & Lower Chains
      for (Point p in upperChain)
        drawPoint(canvasCtx, p, upperChainPointClr);
      for (Point p in lowerChain)
        drawPoint(canvasCtx, p, lowerChainPointClr);

      // Draw step line
      if ((stepNumber > 0) && (stepNumber <= masterPolygon.length)) {
        Point p = getPointAtProcessingIndex(masterPolygon, (stepNumber - 1));
        if (p != null) {
          LineSegment l = new LineSegment(
            new Point(p.x, 0),
            new Point(p.x, canvas.width)
          );
          drawLineSegment(canvasCtx, l, currentLineClr);
        }
      }
    }
  }
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

  // Make sure we have enough points
  checkEnableTriangulateToggle();
  
  // redraw the scene
  drawScene();
}


// For the Canvas, if there is a Right-Click, it will remove a Point from the polygon
void onRightClick(MouseEvent e) {
  // Need to prevent the context menu poping up
  e.preventDefault();

  // Only remove when not triangulating
  if (!triangulating && (masterPolygon.length != 0)) {
    // Pop the most recent
    masterPolygon.removeLast();

    // Make sure we have enough points
   checkEnableTriangulateToggle();

    drawScene();
  }
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


// For the Triangulate button, when it's clicked
// It will toggle the triangulation state
void onTriangulateToggled(var _) {
  // Toggle the triangulation state
  triangulating = !triangulating;

  // init the step through number
  stepNumber = triangulating ? 0 : -1;

  // draw the scene
  drawScene();

  // Set HTML & CSS for the button
  triangulateToggle.text = triangulating ? triangulateToggleOnText : triangulateToggleOffText;
  triangulateToggle.classes.toggle('toggle-on', triangulating);

  // Enable/Disable the Step-Through button if we're triangulating
  stepThroughToggle.disabled = triangulating;

  // Turn on the Step button if we're in step through mode
  if (triangulating && stepThroughMode) {
    stepButton.disabled = false;
    stepButton.text = stepButtonStartText;
  } else {
    // It's not going to do anything
    stepButton.disabled = true;
    stepButton.text = stepButtonText;
  }
}


// For when the Step button is clicked
// This will increment the step count
void onStepButtonClicked(var _) {
  // Do nothing if we're not triangulationg (or done)
  if (!triangulating || (stepNumber == -1))
    return;

  // Increment the step
  stepNumber++;

  // Check if we've stepped enough
  if (stepNumber > masterPolygon.length) {
    stepButton.disabled = true;
    stepButton.text = stepButtonDoneText;
  } else
    stepButton.text = stepButtonText + ' [${stepNumber}]';

  drawScene();
}


void main() {
  // Some testing code for the chains
//  masterPolygon.add(new Point(180, 200));
//  masterPolygon.add(new Point(200, 170));
//  masterPolygon.add(new Point(250, 150));
//  masterPolygon.add(new Point(310, 190));
//  masterPolygon.add(new Point(260, 250));
//  masterPolygon.add(new Point(220, 240));

  // Attach event handlers for the control buttons
  stepThroughToggle.onClick.listen(onStepThroughToggled);
  triangulateToggle.onClick.listen(onTriangulateToggled);
  stepButton.onClick.listen(onStepButtonClicked);

  // Attach event handlers for the Canvas
  canvas.onClick.listen(onLeftClick);
  canvas.onContextMenu.listen(onRightClick);
  canvas.onMouseMove.listen(onMouseMove);
  canvas.onMouseOut.listen(onMouseOut);

  // Draw the scene
  drawScene();

//  print(getNextPoint(new Point(0, 0), [], []));
}

