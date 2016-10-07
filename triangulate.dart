
library triangulate;

import 'dart:html';
import 'dart:math';
import 'stack.dart';
import 'merge-sort.dart';
import 'geometry.dart';


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
ButtonElement clearButton = querySelector('#clear');
ButtonElement triangulateToggle = querySelector('#triangulate-toggle');
ButtonElement stepThroughToggle = querySelector('#step-through-toggle');
ButtonElement stepButton = querySelector('#step');
DivElement stepThroughModeInfoDiv = querySelector('#step-through-mode-info');


// Algorithm HTML section
DivElement case1Div = querySelector('#case-one');
DivElement case2aDiv = querySelector('#case-two-a');
DivElement case2bDiv = querySelector('#case-two-b');


/*== Functions ==*/

// Turns on/off the Triangulate button depending upon the state of the polygon
// Also enables/disables the Clear button
void onPolygonChanged() {
  // Need at least one point to clear out
  clearButton.disabled = (masterPolygon.length < 1);

  // Need at least four points to triangulate
  triangulateToggle.disabled = (masterPolygon.length <= 3);

  // Make sure the polygon is X Montone
  List<Point> upperChain = [], lowerChain = [];
  bool gotChains = getUpperAndLowerChains(masterPolygon, lowerChain, upperChain);
  if (gotChains)
    triangulateToggle.disabled = !(isChainXMonotone(upperChain) && isChainXMonotone(lowerChain));
  else
    triangulateToggle.disabled = true;

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
void drawSceneAndUpdateHTML() {
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
    // Compute a triangulation
    TriangulationResult result = triangulateXMontonePolygon(masterPolygon, stepNumber);

    // Draw the lines
    for (LineSegment l in result.diagonals)
      drawLineSegment(canvasCtx, l, monotoneLineClr); 

    // Do some extra drawing if in step through mode
    if (stepThroughMode) {
      // Draw the Upper & Lower Chains
      for (Point p in upperChain)
        drawPoint(canvasCtx, p, upperChainPointClr);
      for (Point p in lowerChain)
        drawPoint(canvasCtx, p, lowerChainPointClr);

      // Draw step line and Reflex Chain while stepping
      if ((stepNumber > 0) && (stepNumber <= masterPolygon.length)) {
        // Reflex Chain
        for (Point p in result.lastReflexChain.getIter())
          drawPoint(canvasCtx, p, reflexChainClr, true);

        // Current Step Line
        Point p = getPointAtProcessingIndex(masterPolygon, (stepNumber - 1));
        if (p != null) {
          LineSegment l = new LineSegment(
            new Point(p.x, 0),
            new Point(p.x, canvas.width)
          );
          drawLineSegment(canvasCtx, l, currentLineClr);
        }

        // Select the proper algorithm case
        case1Div.classes.toggle('current', result.lastCase == AlgorithmCase.Case1);
        case2aDiv.classes.toggle('current', result.lastCase == AlgorithmCase.Case2a);
        case2bDiv.classes.toggle('current', result.lastCase == AlgorithmCase.Case2b);
      }
    }
  }
}



/*== Event Handlers ==*/
// For when the clear button is pressed, cleans out the Polygon
void onClearButtonClicked(var _) {
  // Alter the polygon
  masterPolygon.clear();
  onPolygonChanged();

  // Redraw
  drawSceneAndUpdateHTML();
}

// For the stepThrough toggle button, Will toggle on/off "step through" mode
void onStepThroughToggled(var _) {
  // Toggle step through mode
  stepThroughMode = !stepThroughMode;

  // Alter the HTML & CSS of the button
  stepThroughToggle.text = stepThroughMode ? stepThroughToggleOnText : stepThroughToggleOffText;
  stepThroughToggle.classes.toggle('toggle-on', stepThroughMode);

  // Alter CSS to show the extra info
  stepThroughModeInfoDiv.style.display = stepThroughMode ? '' : 'none';
}


// For the Canvas, Adds a Point to the Polygon 
void onLeftClick(MouseEvent e) {
  // On Left press, add a Point
  if ((e.button == 0) && !triangulating)
    masterPolygon.add(new Point(e.offset.x, e.offset.y));

  // Make sure we have enough points
  onPolygonChanged();
  
  // redraw the scene
  drawSceneAndUpdateHTML();
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
   onPolygonChanged();

    drawSceneAndUpdateHTML();
  }
}


// For the Canvas, it shows a preview point
void onMouseMove(MouseEvent e) {
  // If in edit more, show a preview of a new point
  if (!triangulating) {
    masterPolygon.add(new Point(e.offset.x, e.offset.y));

    // redraw the scene
    drawSceneAndUpdateHTML();

    // remove that point now
    masterPolygon.removeLast();
  }
}


// For the Canvas, if the mouse was moved out, it will redraw the scene
// This is so we don't have any left-over preview lines
void onMouseOut(var _) =>
  drawSceneAndUpdateHTML();


// For the Triangulate button, when it's clicked
// It will toggle the triangulation state
void onTriangulateToggled(var _) {
  // Toggle the triangulation state
  triangulating = !triangulating;

  // init the step through number
  stepNumber = triangulating ? 0 : -1;

  // draw the scene
  drawSceneAndUpdateHTML();

  // Set HTML & CSS for the button
  triangulateToggle.text = triangulating ? triangulateToggleOnText : triangulateToggleOffText;
  triangulateToggle.classes.toggle('toggle-on', triangulating);

  // Enable/Disable other button presses
  stepThroughToggle.disabled = triangulating;
  clearButton.disabled = triangulating;

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

    // Un-highlight all of the cases
    case1Div.classes.toggle('current', false);
    case2aDiv.classes.toggle('current', false);
    case2bDiv.classes.toggle('current', false);
  } else
    stepButton.text = stepButtonText + ' [${stepNumber}]';

  drawSceneAndUpdateHTML();
}


void main() {
  // Attach event handlers for the control buttons
  clearButton.onClick.listen(onClearButtonClicked);
  stepThroughToggle.onClick.listen(onStepThroughToggled);
  triangulateToggle.onClick.listen(onTriangulateToggled);
  stepButton.onClick.listen(onStepButtonClicked);

  // Attach event handlers for the Canvas
  canvas.onClick.listen(onLeftClick);
  canvas.onContextMenu.listen(onRightClick);
  canvas.onMouseMove.listen(onMouseMove);
  canvas.onMouseOut.listen(onMouseOut);

  // Draw the scene
  drawSceneAndUpdateHTML();
}

