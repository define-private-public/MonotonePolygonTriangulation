
library triangulate;

import 'dart:html';
import 'merge-sort.dart';
import 'comparable-point.dart';

/*== Functions ==*/
// Makes a nice RGB value
String rgb(int r, int g, int b) =>
  'rgb($r, $g, $b)';


/*== Some constants ==*/
// Canvas colors
String backgroundClr = rgb(0, 46, 76);
String monotoneLineClr = rgb(153, 214, 255);
String nonMonotoneLineClr = rgb(255, 51, 51);
String upperChainPointClr = rgb(0, 0xFF, 0);
String lowerChainPointClr = rgb(0, 0, 0xFF);
String reflexChainClr = rgb(0xFF, 0, 0);
String currentLineClr = rgb(0xFF, 0x00, 0x00);

// Algorithm Case colors
String caseInactiveClr = rgb(0xFF, 0xFF, 0xFF);
String caseActiveClr = rgb(153, 214, 255);


// Interactive HTML section
CanvasElement canvas = querySelector('#polygon-canvas');
CanvasRenderingContext2D ctx = canvas.context2D;
ButtonElement triangulateButton = querySelector('#triangulate');
ButtonElement stepThroughToggle = querySelector('#step-through-toggle');
ButtonElement stepButton = querySelector('#step');


/*== TODO Info section ==*/

// Algorithm HTML section
DivElement case1Div = querySelector('#case-one');
DivElement case2aDiv = querySelector('#case-two-a');
DivElement case2bDiv = querySelector('#case-two-b');



void main() {
  // Fill the background
  ctx..fillStyle = backgroundClr
     ..fillRect(0, 0, canvas.width, canvas.height);
}

