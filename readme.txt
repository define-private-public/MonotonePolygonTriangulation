Polygon Triangulation Teaching Tool

My project for the course was to create a teaching to for the polygon
triangulation algorithm discussed in class.  It will only triangulate X-Monotone
polyogns.

How-To Use:
 1. Click on the blue area to add points
 2. Add you points in a clockwise fasion (triangulation will not work)
 3. If the polygon becomes red, that means that it is no-longer X-Monotone
 4. Once you are happy with you polgyon, press "Triangulate." to see the
    subdivisions.
 5. If you want to step through your triangulation, press the "Step Through,"
    button.  To step to the next point, press the "Step," button
     - In this mode, the algorithm on the right will light up depending upon
       what the next point is.
     - Points on the upper chain are green, on the lower chain are blue
     - Points on the reflex chain are marked in red
     - The location of the Scan line is marked in red
     - There is some extra info displayed at the bottom.


Why triangulation might fail sometimes
----
This has to do with my algorithm for splitting up the polygon into the lower and
upper chains.  This will only happen if you input the points in a
counter-clockwise fashion.  To avoid this issue, just put them in clockwise.
You can put a start point anywhere though (e.g. the lower right corner).

