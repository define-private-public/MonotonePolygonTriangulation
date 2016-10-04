// gemoetry.dart
//
// This file is a collection of Geometric classes and function that will be used
// throughout the program.

library triangulate;

import 'dart:io';


// Point class, not using Dart's builting because its XY coords are final vars
// This one can also be sorted along the X axis
class Point {
  num x;
  num y;


  Point(num x_, num y_) :
    x = x_,
    y = y_;


  void setFrom(Point other) {
    x = other.x;
    y = other.y;
  }


  String toString() =>
   '(' + x.toString() + ', ' + y.toString() + ')';


  Point copy() =>
    new Point(x, y);


  // Only checks for equality on the X axis
  @override
  bool operator ==(Point other) =>
    x == other.x;

  @override
  bool operator <(Point other) =>
    x < other.x;

  @override
  bool operator <=(Point other) =>
    x <= other.x;

  @override
  bool operator >(Point other) =>
    x > other.x;

  @override
  bool operator >=(Point other) =>
    x >= other.x;

}


// A class representing a line segment
class LineSegment {
  // Endpoints of the line segment
  Point a;
  Point b;

  // TODO test if this is making a copy or its own thing
  LineSegment (Point a_, Point b_) :
    a = a_.copy(),
    b = b_.copy();

  // TODO test if this is making a copy or its own thing
  LineSegment copy() =>
    new LineSegment(a, b);

  
  String toString() =>
    '{ ' + a.toString() + ' -- ' + b.toString() + ' }';
}



void main() {
  Point a = new Point(2, 3);
  Point b = a.copy();
  LineSegment l1 = new LineSegment(a, b);

  a.x = -4;
  print(a);
  print(b);

  print(l1);

  LineSegment l2 = l1.copy();
  l2.b.y = 0;
  print(l1);
  print(l2);
}

