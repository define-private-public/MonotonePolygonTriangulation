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


// Checks if a List of Points (treated as a Chain) only ever increase or
// decrease in the X axis (this means that it's X Monotone)
// If a Chain has two same points, it will not be considered Monotone
bool isChainXMonotone(List<Point> chain) {
  // Need at least two Points to be a Chain
  // If only two points in the chain, it's automatically Monotone
  if (chain.length < 2)
    return false;
  else if (chain.length == 2)
    return true;

  // First test if it's ascending monotone
  bool ascendingMonotone = true;
  num x = double.NEGATIVE_INFINITY;

  for (Point p in chain) {
    // Did we find a point that's less than the current X?
    if (p.x <= x) {
      ascendingMonotone = false;
      break;
    }

    x = p.x;
  }

  // Are we ascending Monotone?
  if (ascendingMonotone)
    return true;


  // Check for descending Monotone
  bool descendingMonontone = true;
  x = double.INFINITY;

  for (Point p in chain) {
    // Is there a point greater than the current X?
    if (p.x >= x) {
      descendingMonontone = false;
      break;
    }

    x = p.x;
  }

  return descendingMonontone;
}


// This function will retrive the upper and lower chains of a Polygon
//   polygon - a List of Points that make up a (closed) polygon
//   uc - a pointer to a List<Point>, will be the upper chain
//        must be allocated before being passed in
//   lc - a pointer to a List<Point>, will be the lower chain
//        must be allocated before being passed in
//
//   Returns: true if the upper and lower chains were successfully pulled out
//            false otherwise, this also means that the output chains will be
//            empty.
//
// Note that the two return chains will include duplicate points.  These
// will always be the first and last elements of each chain.  The chains should
// return an ascending X value (if given an X Montone Polygon)
bool getUpperAndLowerChains(List<Point> polygon, List<Point> uc, List<Point> lc) {
  // Clear out the chains
  uc.clear();
  lc.clear();

  // Need at least three poits
  if (polygon.length < 3)
    return false;

  // Need to search through a bit

  return true;
}




//void main() {
//  Point a = new Point(0, 0);
//  Point b = new Point(4, 0);
//  Point c = new Point(6, 0);
//  Point d = new Point(8, 0);
//  Point e = new Point(9, 0);
//
//  List<Point> chain = [a, b, c, d, e];
//  print(chain);
//  print(isChainXMonotone(chain));
//
//  chain = [e, d, c, b, a];
//  print(chain);
//  print(isChainXMonotone(chain));
//}

