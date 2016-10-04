// gemoetry.dart
//
// This file is a collection of Geometric classes and function that will be used
// throughout the program.

library triangulate;

//import 'dart:io';


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
  Line(Point a_, Point b_) :
    a = a_,
    b = b_;

  // TODO test if this is making a copy or its own thing
  Line copy() =>
    new Line(a, b);

  
  toString() =>
    '{ ' + a.toString() + ' -- ' + b.toString() + ' }';
}


