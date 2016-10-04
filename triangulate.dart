
library triangulate;

import 'dart:html';
import 'stack.dart';
import 'merge-sort.dart';
import 'comparable-point.dart';


/*== Global State Variables ==*/
// yes, yes... I know they are a bad practice to use, but they make this demo easier to write
bool stepThroughMode = false;


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

// Text
const String stepThroughToggleOffText = 'Step Through [Off]';
const String stepThroughToggleOnText = 'Step Through [On]';


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
  ctx..fillStyle = backgroundClr
     ..fillRect(0, 0, canvas.width, canvas.height);

  Stack<num> stack = new Stack<num>();
  stack.push(1);
  stack.push(1.3);
  stack.push(5);
  var s2 = stack.copy();
  print(stack);
  print(stack.pop());
  print(stack.size());
  print(stack);
  stack.clear();
  print(stack);
  print(s2);

}

