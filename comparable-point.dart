
library triangulate;

import 'dart:io';
import 'merge-sort.dart';

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


  String toString() {
    return '(' + x.toString() + ', ' + y.toString() + ')';
  }


  Point copy() {
    return new Point(x, y);
  }


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


void main() {
  List<Point> points = [
    new Point(0, 2),
    new Point(-1, 8),
    new Point(7.4, 0),
    new Point(5, -2),
    new Point(10.1, 1),
    new Point(7.3, -1),
    new Point(-5.8, 0.3),
  ];

  print(points);
  print(mergesort(points));
}

