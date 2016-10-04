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


// Computes the Determinant of a Line and a Point
// (see: https://en.wikipedia.org/wiki/Determinant)
// This is used to see if a Point lies left, right or on top of a Line
//
//   a -- First Point on the Line
//   b -- Second Point on the Line
//   p -- The Point to test
//
//   If the return value is positive, p lies to the left of the Line
//   If the return value is negative, p lies to the right of the Line
//   If the return value is zero, p lies on the Line
//
//   All of these are realative to the direction a -> b.  It might be
//   best to think of those two points defining a Vector.
num determinant(Point a, Point b, Point p) =>
  (a.x * (b.y - p.y)) + (b.x * (p.y - a.y)) + (p.x * (a.y - b.y));





void main() {
  Point a = new Point(0, 0);
  Point b = new Point(4, 0);

  Point p1 = new Point(2, 1);
  Point p2 = new Point(2, 0);
  Point p3 = new Point(2, -1);

  print(p1);
  print(determinant(a, b, p1));
  print(p2);
  print(determinant(a, b, p2));
  print(p3);
  print(determinant(a, b, p3));
}

