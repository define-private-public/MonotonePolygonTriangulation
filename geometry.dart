// gemoetry.dart
//
// This file is a collection of Geometric classes and function that will be used
// throughout the program.

library triangulate;

//import 'dart:io';
import 'stack.dart';


// Used when pulling off points from the chains
enum FromChain {
  None,
  Upper,
  Lower
}



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


  bool equals(Point other) =>
    (x == other.x) && (y == other.y);


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

  // Creates a LingSegment by copying the two point values
  LineSegment (Point a_, Point b_) :
    a = a_.copy(),
    b = b_.copy();

  // Creates a deep copy of the LineSegment
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
// If a Chain has two Points that have the same X value, it will be considered Monotone
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
    if (p.x < x) {
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
    if (p.x > x) {
      descendingMonontone = false;
      break;
    }

    x = p.x;
  }

  return descendingMonontone;
}


// This function will retrive the upper and lower chains of a Polygon in O(N) time
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

  // Need to search through a bit to find the endpoints
  Point leftmostPoint = new Point(double.INFINITY, 0);
  Point rightmostPoint = new Point(double.NEGATIVE_INFINITY, 0);
  int leftmostIndex;
  int rightmostIndex;

  // Get them O(N)
  for (int i = 0; i < polygon.length; i++) {
    Point p = polygon[i];

    // Compares on the X axis (check Point class source)
    if (p < leftmostPoint) {
      leftmostPoint.setFrom(p);
      leftmostIndex = i;
    }

    if (p > rightmostPoint) {
      rightmostPoint.setFrom(p);
      rightmostIndex = i;
    }
  }

  // Get the upper chain
  // Find which direciton to travel in
  Point next = polygon[(leftmostIndex + 1) % polygon.length];
  Point prev = polygon[(leftmostIndex - 1) % polygon.length];

  int dir = 0;
  if (next.y > prev.y)
    dir = 1;
  else
    dir = -1;

  // An anonymouse function that will populate a chain from left to right
  // with a directoin
  var mkChain = (chain, direction) {
    // Loop until we hit the rightmost Point
    bool done = false;
    int cursor = leftmostIndex;
    while (!done) {
      // Next point
      Point p = polygon[cursor % polygon.length];
      cursor += direction;

      // Add to chain
      chain.add(p);

      // Check if we've reached the end
      if (p.equals(rightmostPoint))
        done = true;
    }
  };

  // Makes the chains
  mkChain(uc, dir);
  mkChain(lc, -1 * dir);

  return true;
}


// Pulls off Points from the upper and lower chains.  All paramters need to be
// instantiated before calling this funciton.  This will (possibly) modify the
// values of all parameters.
//
//   p -- The Point that has been pulled off
//   upperChain -- The upper chain of the Polygon
//   lowerChain -- The upper chain of the Polygon
//
// This function returns which Chain the Point was pulled off of.  If
// FromChain.None is returned, then there are no points on the chains.
FromChain getNextPoint(Point p, List<Point> upperChain, List<Point> lowerChain) {
  int uLen = upperChain.length;
  int lLen = lowerChain.length;

  // If both chains are empty, return None
  if ((uLen == 0) && (lLen == 0))
    return FromChain.None;

  // If one chain is emtpy but the other is not, pop a Point
  if (lLen == 0) {
    // Upper Chain has stuff
    p.setFrom(upperChain.removeAt(0));
    return FromChain.Upper;
  } else if (uLen == 0) {
    // Lower Chain has stuff
    p.setFrom(lowerchain.removeAt(0));
    return FromChain.Lower;
  }

  // Whichover one has the lower X value is poped next
  num uX = upperChain[0].x;
  num lX = lowerChain[0].x;
  
  if (uX <= lX) {
    // Upper Chain 
    p.setFrom(upperChain.removeAt(0));
    return FromChain.Upper;
  } else if (lX < uX) {
    // Lower Chain has stuff
    p.setFrom(lowerchain.removeAt(0));
    return FromChain.Lower;
  }
}


// Does the Triangulation of the Polygon
//   polygon -- a List of Points that is an X Monotone polygon
//
// Returns a List of LineSegments, that are the diagonals that create the
// triangulated Polygon.
// TODO step for reflex chain
List<LineSegment> getDiagonals(List<Point> polygon) {
  List<LineSegment> diagonals = [];

  // Need at least 4 points to triangulate
  if (polygon.length < 4)
    return diagonals;

  // Get the Chains
  List<Point> upperChain = [], lowerChain = [];
  getUpperAndLowerChains(masterPolygon, upperChain, lowerChain);
  lowerChain.removeAt(0);   // Pop off first/last of lower (remove duplicates)
  lowerChain.removeLast();

  // Reflex Chain
  Stack<Point> reflexChain = [];
  FromChain relfexOnSide = FromChain.None;

  // Put the first two points onto the reflex chain
  // First Point
  Point p = new Point(0, 0);
  FromChain side = getNextPoint(p, upperChain, lowerChain);
  relfexChain.push(p);

  // Second point
  side = getNextPoint(p, upperChain, lowerChain);
  relfextChain.push(p);

  // Loop through creating the diagonals, peel of each Point
  FromChain prevSide = side;
  side = getNextPoint(p, upperChain, lowerChain);
  while (side != FromChain.None) {
    if (side != lastSide) {
      // Case 1, p is on the opposite side of the Reflex Chain

      // Get the first Point off, it will be our new 'u'
      bool gotFirst = false;
      Point u;

      // Make the diagonals to all of the Points on the Relfex Chain, except for the last one
      // TODO refactor this blow, it's kind of bad
      while(relfexChain.size() > 1) {
        // Pop from stack & make a diagonal
        Point v = reflexChain.pop();
        diagonals.add(new LineSegment(v, p));

        if (!gotFirst) {
          u = v;
          gotFirst = true;
        }
      }

      // Ignore the last one
      reflexChain.pop();

      // The first point and the last are now on the Relfex Chain
      relfexChain.push(u);
      relfexChain.push(p);
    } else {
      // Case 2, p is on the same side of the Reflex Chain
    }
  }




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

