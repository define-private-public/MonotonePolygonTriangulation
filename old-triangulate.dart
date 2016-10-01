
library triangulate;

import 'dart:html';


// #defines
const int CHAINS_EMPTY = 0;
const int UPPER_CHAIN = 1;
const int LOWER_CHAIN = 2;
const int CASE_INVALID = 0;
const int CASE_1 = 1;
const int CASE_2A = 2;
const int CASE_2B = 3;

// Important global variables
int width = 800;
int height = 640;
List<Point> master_polygon = new List();
bool triangulate = false;
bool step_through = false;
int max_num_steps = 1;                  // For step-through mode
bool stepping_done = false;             // For step-through mode
int step_case = CASE_INVALID;           // For step-through mode
int info_x = -1;                        // for step-through mode
Stack<Point> info_reflex_chain = new Stack<Point>();         // for step-through mode


// HTML
DivElement content = querySelector('#content');
CanvasElement c = new CanvasElement(width: width, height: height);
ButtonElement triangulate_button = querySelector('#triangulate');
ButtonElement step_through_button = querySelector('#step_through');
ButtonElement step_button = querySelector('#step');

// HTML Info
DivElement div_info_side = querySelector('#info_side');
DivElement div_info_p = querySelector('#info_p');
DivElement div_info_reflex_chain = querySelector('#info_reflex_chain');
DivElement div_info_upper_chain = querySelector('#info_upper_chain');
DivElement div_info_lower_chain = querySelector('#info_lower_chain');


// A simple LIFO implementation (because dart wont give us one)
class Stack<T> {
  List<T> l;

  Stack() :
    l = new List<T>();


  int size() =>
    l.length;


  void push(T x) {
    l.add(x);
  }


  T pop() {
    return l.removeLast();
  }


  T peek(int index) {
    return l[this.size() - index - 1];
  }
  

  Iterable<T> getIter() {
    return l.reversed;
  }


  Stack<T> copy() {
    Stack<T> c = new Stack<T>();

    for (T item in l)
      c.push(item.copy());

    return c;
  }


  void clear() {
    l.clear();
  }

  
  String toString() {
    String str = '[ ';
    
    for (int i = 0; i < this.size(); i++) {
      str += this.peek(i).toString();

      // Add on commas
      if (i != (this.size() - 1))
        str += ', ';
    }

    str += ' ]';
    return str;
  }



}



// Point class, not using Dart's builting because its XY coords are final vars
class Point {
  num x;
  num y;

  Point(num _x, num _y) :
    x = _x,
    y = _y;

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

}


// A simple line class
class Line {
  Point a;
  Point b;

  Line(Point _a, Point _b) :
    a = new Point(_a.x, _a.y),
    b = new Point(_b.x, _b.y);


  Line copy() {
    return new Line(a.copy(), b.copy());
  }


  String toString() {
    return a.toString() + '->' + b.toString();
  }

}


// Simple handy function
void print(var msg) {
  window.console.debug(msg);
}

String sideStr(int side) {
  if (side == CHAINS_EMPTY)
    return 'Chains Empty';
  else if (side == UPPER_CHAIN)
    return 'Upper Chain';
  else if (side == LOWER_CHAIN)
    return 'Lower Chain';
  else
    return 'Wat?';
}


// finds the dterminate of a a point and a line
num deter(a, b, p) {
  // a -- first endpoint of the line
  // b -- second endpoint of the line
  // p -- the point
  // If return value is postive, point is to to the right of the line
  // If return value is negative, point is to the left of the line
  // - means that it's on the line
  return ((b.x * p.y) + (a.x * b.y) + (a.y * p.x)) - ((a.y * b.x) + (a.x * p.y) + (b.y * p.x));
}


// Get the montone chains
void getChains(List<Point> polygon, List<Point> upper_chain, List<Point> lower_chain) {
  // polygon -- a Series of points (in order they should be drawn, doesn't matter what is the first one)
  // upper_chain -- list of points of the upper chain (includes left_most and right_most)
  // lower_chain -- list of points of the lower chain (includes left_most and right_most)

  // do nothing if there are two elements
  if (polygon.length < 3)
    return;

  // Create new objects
  upper_chain.clear();
  lower_chain.clear();

  // Find the leftmost and the rightmost points, as well as ther indices
  int left = 999999, right = -1;
  int li, ri;         // Indices
  for (int i = 0; i < polygon.length; i++) {
    Point p = polygon[i];
    
    // Check for leftmost and rightmost
    if (p.x < left) {
      // Leftmost
      left = p.x;
      li = i;
    }

    if (p.x > right) {
      // Rightmost
      right = p.x;
      ri = i;
    }
  }
 
  // some vars
  Point p;
  int i = 0;

  // Construct the upper chain  (left->right)
  i = li;
  p = polygon[i];
  upper_chain.add(p);
  while (i != ri) {
    // Rollover
    if (i == (polygon.length - 1))
      i = 0;
    else
      i++;
   
    // goto the next
    p = polygon[i];
    upper_chain.add(p);
  }

  // constrcut the lower chain (right -> left)
  i = ri;
  p = polygon[i];
  List<Point> lc = new List<Point>();
  lc.add(p);
  while (i != li) {
    // Rollover
    if (i == (polygon.length - 1))
      i = 0;
    else
      i++;
   
    // goto the next
    p = polygon[i];
    lc.add(p);
  }

  // Now reverse the lower chain
  for (Point p in lc.reversed)
    lower_chain.add(p);

  // Pop off endpoints
  upper_chain.removeAt(0);
  upper_chain.removeLast();
}


int getNextPoint(Point p, List<Point> upper_chain, List<Point> lower_chain) {
  // Will take in the upper and lower chains, then peel of the next
  // point.  It will modify the state of the chains.  p is the point,
  // and return value will either be UPPER_CHAIN or LOWER_CHAIN, or
  // CHAINS_EMPTY if there are no points

  // init some defaults
  p.x = -1;
  p.y = -1;

  // First check if there are elements
  int u_len = upper_chain.length;
  int l_len = lower_chain.length;
  if ((u_len == 0) && (l_len == 0))
    return CHAINS_EMPTY;

  // If one chain is empty, but the other is not, then return a point from the other one
  // First point is guarenteerd to be the smallest X value
  if (l_len == 0) {
    p.setFrom(upper_chain.removeAt(0));
    return UPPER_CHAIN;
  }  else if (u_len == 0) {
    p.setFrom(lower_chain.removeAt(0));
    return LOWER_CHAIN;
  }

  // There must be points in both chains, find the one with the lower X Value
  // TODO should not share X values, but if there is one, it defualts to the upper chain
  int u_x = upper_chain[0].x;
  int l_x = lower_chain[0].x;
  if (u_x <= l_x) {
    p.setFrom(upper_chain.removeAt(0));
    return UPPER_CHAIN;
  } else if (l_x < u_x) {
    // Lower chain must be less
    p.setFrom(lower_chain.removeAt(0));
    return LOWER_CHAIN;
  }

  // NOTE should never reach this place, but if it happens, a (-1, -1) will be returned for p
  return CHAINS_EMPTY;
}

// Checks to see if a chain is montone or not, in the x axis
bool isChainMonotone(List<Point> chain) {
  // Very simple solution, just get an starting X value, and always make sure it increases
  int x = -1;   // Should never be this

  // The gauntlet
  for (Point p in chain) {
    // Check if current point is less than X
    if (p.x < x)
      return false;

    // Else, set X and continue
    x = p.x;
  }

  return true;  // Past the gauntlet
}


// Triangulates the polygon and obtains the diagonals
void getDiagonals(List<Point> polygon, List<Line> diagonals) {
  // Check the lengths, if less than 4, just exit
  if (polygon.length < 4)
    return;

  // Setup some things for stepping through
  int step_num = 0;

  // Okay, we have something to triangulate, get the chains
  List<Point> upper_chain = new List<Point>(), lower_chain = new List<Point>();
  getChains(polygon, upper_chain, lower_chain);
  Stack<Point> reflex_chain = new Stack<Point>();   // Use 'add()' and 'removeLast()' for push/pop stack
  int reflex_on = -1;                            // Reflex is currently on no china

  // Put the first two points on the reflex chain
  Point p = new Point(-1, -1);
  int side = getNextPoint(p, upper_chain, lower_chain);         // The current side of the reflex chain
  int last_side = side;
  reflex_chain.push(p.copy());

  // SEcond point
  side = getNextPoint(p, upper_chain, lower_chain);
  reflex_chain.push(p.copy());
  

  // Loop through creating the diagonals
  // Peel off each point
  last_side = side;
  side = getNextPoint(p, upper_chain, lower_chain);
  while (side != CHAINS_EMPTY) {
    // done debug information
//    print('Chain:');
//    print(reflex_chain.toString());
//    print('Side: ' + sideStr(side));
//    print('Last Side: ' + sideStr(last_side));


    // Do the actual algorithm
    if (side != last_side) {
      // Case 1, p is on the opposite side of the chain
//      print('Case 1');
      step_case = CASE_1;

      // Get the first point off, it will be our new 'u'
      bool got_first = false;
      Point first;

      // Make diagonals to all points, except for the last one
      while (reflex_chain.size() > 1) {
        // Get the points from the top of the stack, and make diagonals
        Point v = reflex_chain.pop();
        diagonals.add(new Line(v, p));

        if (!got_first) {
            first = v;
            got_first = true;
        }
      }

      // Just ignore the last one
      reflex_chain.pop();

      // the first point on the stack and p are now on the stack
      reflex_chain.push(first.copy());
      reflex_chain.push(p.copy());

    } else {
//      print('Case 2');
      // case 2, p is on the same side of the chain
      // depending upon the side, switch how the determinate works
      Point b = reflex_chain.peek(0);
      Point a = reflex_chain.peek(1);
      int d = deter(a, b, p);
      bool case_a = false;

      if (side == UPPER_CHAIN) {
        // If the reflex in on the upper chain, check for a postive determinate for case a
        if (d > 0)
          case_a = true;
      } else if (side == LOWER_CHAIN) {
        // If the reflex is on the lower, we want a negative deter for case a
        if (d < 0)
          case_a = true;
      }

      if (case_a) {
//        print('Case 2a');
        step_case = CASE_2A;
        // Case 2a, add diagonals based upon visibility
        // We must add at least one diagonal
        bool done = false;

        while (!done) {
          // Stop checking after we haven't added one
          b = reflex_chain.peek(0);
          a = reflex_chain.peek(1);
          d = deter(a, b, p);

          // Choose where to add the diagonal
          bool add_diag = false;
          if (side == UPPER_CHAIN) {
            if (d > 0) {
              add_diag = true;
            }
          } else if (side == LOWER_CHAIN) {
            if (d < 0) {
              add_diag = true;
            }
          }

          // Either add a diagonal, or stop adding them
          if (add_diag) {
              // Add on the diagonal b->p, remove a from the reflex chain
              diagonals.add(new Line(a, p));
              reflex_chain.pop();

              // Add everyting but the last vertex
              if (reflex_chain.size()< 2)
                done = true;
          } else
            done = true;
        }

        // Add on p to the reflex chain
        reflex_chain.push(p.copy());

      } else {
        // Case 2b, add vertex onto the reflex chain
//        print('Case 2b');
        step_case = CASE_2B;
        reflex_chain.push(p.copy());
      }
    }



    // First add the stuff to the stepping points
    if (step_through) {
      step_num += 1;
      info_x = p.x;
      info_reflex_chain.clear();
      info_reflex_chain = reflex_chain.copy();

      // Display some HTML info
      div_info_side.text = 'Side: ' + sideStr(side);
      div_info_p.text = 'p: ' + p.toString();
      div_info_reflex_chain.text = 'Reflex Chain: ' + reflex_chain.toString();
      div_info_upper_chain.text = 'Upper Chain: ' + upper_chain.toString();
      div_info_lower_chain.text = 'Lower Chain: ' + lower_chain.toString();
  
      // Break out if we've done enough already
      if (step_num >= max_num_steps)
        break;
    }
//    print('');

    // Get the next point to process
    last_side = side;
    side = getNextPoint(p, upper_chain, lower_chain);
  }
//  print('------------');
//  print('');

  // If stepping and we've gone through the entire algorithm, just shut it down, once we are here, we should be done
  if (step_through && (side == CHAINS_EMPTY)) {
    // Completed a success step-through, turn off everyting
    stepping_done = true;
    step_button.disabled = true;
    step_case = CASE_INVALID;
    info_x = -1;    // Reset
    info_reflex_chain.clear();
  }
}





// Makes a nice RGB values
String rgb(int r, int g, int b) => 'rgb($r, $g, $b)';


// Draws a polygon
void drawPolygon(CanvasRenderingContext2D ctx, List<Point> poly, String clr) {
  // Make sure we have at least three
  if (poly.length < 1)
    return;

  // Draw the first point
  Point first = poly[0];
  ctx..beginPath()
     ..lineWidth = 2
     ..strokeStyle = clr
     ..moveTo(first.x, first.y);

  // Draw the lines
  for (int i = 1; i < poly.length; i++) {
    Point p = poly[i];
    ctx.lineTo(p.x, p.y);
  }

  // Finish up the line
  ctx..closePath()
     ..stroke();
}

void drawLine(CanvasRenderingContext2D ctx, Line line, String clr) {
  // Just draws a line
  ctx..beginPath()
     ..lineWidth = 2
     ..strokeStyle = clr
     ..moveTo(line.a.x, line.a.y)
     ..lineTo(line.b.x, line.b.y)
     ..closePath()
     ..stroke();

}


// Adds a point to the polygon
void onMouseButtonClick(MouseEvent event) {
  if ((event.button == 0) && (!triangulate)) {
    // Left Button press, add
    master_polygon.add(new Point(event.client.x, event.client.y));
  }

  // Draw the scene
  drawScene();
}

// Adds a point temporarly
void onMouseMove(MouseEvent event) {
  // If still in editing mode, show preview of new polygon
  if (!triangulate)
    master_polygon.add(new Point(event.client.x, event.client.y));

  // Draw the scene
  drawScene();

  // See above
  if (!triangulate)
    master_polygon.removeLast();
}

// Justs redraws the scene
void onMouseOut(MouseEvent event) {
  drawScene();
}

void onRightClick(MouseEvent event) {
  event.preventDefault();

  // If triangulating, don't add/remove
  if (!triangulate)
    master_polygon.removeLast();

  drawScene();
} 


void drawScene() {

  // Get the chains
  List<Point> uc = new List<Point>(), lc = new List<Point>();
  getChains(master_polygon, uc, lc);

  // Check for Monotone
  var isMonotone = isChainMonotone(uc) && isChainMonotone(lc);
  var clr = isMonotone ? rgb(153, 214, 255) : rgb(255, 51, 51);

  // Draw the points
  CanvasRenderingContext2D ctx = c.context2D;
  ctx..fillStyle = rgb(0, 46, 76)
     ..fillRect(0, 0, c.width, c.height);
  drawPolygon(ctx, master_polygon, clr);


  // Get the diagonals
  if (isMonotone && triangulate) {
    List<Line> diagonals = new List<Line>();
    getDiagonals(master_polygon, diagonals);

    // Draw the diagonals
//    window.console.debug('Diagonals:');
    for (Line l in diagonals) {
//      window.console.debug(l.toString());
      drawLine(ctx, l, clr);
    }

    // Draw some extra info if we are in step-through mode
    if (step_through) {

      // Draw the upper and lower chains
      for (Point p in uc) {
        ctx..fillStyle = rgb(0x00, 0xFF, 0x00)
           ..fillRect(p.x - 4, p.y - 4, 8, 8);
      }
      for (Point p in lc){
        ctx..fillStyle = rgb(0x00, 0x00, 0xFF)
           ..fillRect(p.x - 4, p.y - 4, 8, 8);
      }

      // Draw the reflex chain
      for (Point p in info_reflex_chain.getIter()) {
        ctx..fillStyle = rgb(0xFF, 0x00, 0x00)
           ..fillRect(p.x - 5, p.y - 5, 10, 10);
      }
      
      // Draw the current line
      Line l = new Line(new Point(info_x, 0), new Point(info_x, height));
      drawLine(ctx, l, rgb(0xFF, 0x00, 0x00));
    }
  }


  // Highlight the algorithm if setpping through
  if (step_through) {
      DivElement d_case_1 = querySelector('#case_1');
      DivElement d_case_2a = querySelector('#case_2a');
      DivElement d_case_2b = querySelector('#case_2b');

      // Turn them all white first
      d_case_1.style.background = 'white';
      d_case_2a.style.background = 'white';
      d_case_2b.style.background = 'white';

      // Turn on which one
      switch (step_case) {
        case CASE_1:
          d_case_1.style.background = rgb(153, 214, 255);
          break;
        case CASE_2A:
          d_case_2a.style.background = rgb(153, 214, 255);
          break;
        case CASE_2B:
          d_case_2b.style.background = rgb(153, 214, 255);
          break;
      }
  }
}


void onTriangulateClick(var e) {
  if (triangulate) {
    // Turn triangulation off
    triangulate = false;
	triangulate_button.text = 'Triangulate [Off]';
    step_through_button.disabled = false;
    step_button.disabled = true;

    // Clear out the div text
    div_info_side.text = '';
    div_info_p.text = '';
    div_info_reflex_chain.text = '';
    div_info_upper_chain.text = '';
    div_info_lower_chain.text = '';

    // Reset
    info_x = -1;

  } else {
    // Turn Triangulation on
    triangulate = true;
	triangulate_button.text = 'Triangulate [On]';

    // Reset some varaibles
    max_num_steps = 1;
    stepping_done = false;
    step_button..text = 'Step=1'              // The stepping button
               ..disabled = !step_through;
    step_through_button.disabled = true;
  }

  drawScene();
}


void onStepThroughClick(var e) {
  if (step_through) {
    step_through = false;
    step_through_button.text = 'Step Through [Off]';
  } else {
    // Turn Step though on
    step_through = true;
    step_through_button.text = 'Step Through [On]';
  }
}


void onStepClick(var e) {
  // Only do sometthing on stepthrough mode, and we're not done
  if (!step_through || stepping_done)
    return;

  // We're good to icnrease the step, and draw again
  max_num_steps += 1;
  step_button.text = 'Step=' + max_num_steps.toString();

  // Draw the scene
  drawScene();


  // Update the info section
  div_info_side.text = '';
  div_info_p.text = '';
  div_info_reflex_chain.text = '';
  div_info_upper_chain.text = '';
  div_info_lower_chain.text = '';

}



// Main function
void main() {
  // Set the buttons
  triangulate_button..text = 'Triangulate [Off]'
                    ..onClick.listen(onTriangulateClick);
  step_through_button..text = 'Step Through [Off]'
                     ..onClick.listen(onStepThroughClick);
  step_button..text = 'Step=1'
             ..disabled = true
             ..onClick.listen(onStepClick);


  // Get the info stuff

  // Test the stack
//  Stack<Point> s = new Stack<Point>();
//  s.push(new Point(5, 5));
//  s.push(new Point(10, 10));
//  s.push(new Point(-15, 15));
//  print(s.toString());
//  print(s.pop());
//  print(s.toString());
//  print(s.peek(0));
//  print(s.peek(1));
//  s.pop();
//  s.pop();
//  print(s.toString());


  // Add on and draw
  content.append(c);
  c.onClick.listen(onMouseButtonClick);
  c.onContextMenu.listen(onRightClick);
  c.onMouseMove.listen(onMouseMove);
  c.onMouseOut.listen(onMouseOut);
  drawScene();
}

