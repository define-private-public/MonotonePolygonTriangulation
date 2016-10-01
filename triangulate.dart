
library triangulate;

import 'dart:html';
import 'merge-sort.dart';
import 'comparable-point.dart';


// Makes a nice RGB values
String rgb(int r, int g, int b) => 'rgb($r, $g, $b)';


void main() {
  CanvasElement canvas = querySelector('#polygon-canvas');

  // Fill the background
  CanvasRenderingContext2D ctx = canvas.context2D;
  ctx..fillStyle = rgb(0, 46, 76)
     ..fillRect(0, 0, canvas.width, canvas.height);
}

