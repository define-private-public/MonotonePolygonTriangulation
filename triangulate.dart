
library triangulate;

import 'dart:html';
import 'merge-sort.dart';
import 'comparable-point.dart';


// Makes a nice RGB value
String rgb(int r, int g, int b) =>
  'rgb($r, $g, $b)';

// Some constants
string backgroundColor = rgb(0, 46, 76);


// Interactive section
CanvasElement canvas = querySelector('#polygon-canvas');
CanvasRenderingContext2D ctx = canvas.context2D;



void main() {
  // Fill the background
  ctx..fillStyle = backgroundColor
     ..fillRect(0, 0, canvas.width, canvas.height);
}

