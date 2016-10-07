Monotone Polygon Triangulation Demo
===================================

Live Demo: https://16bpp.net/page/monotone-polygon-triangulation

Back in my fourth year of university, I was taking a course in Computational
Geometry.  As an final project for the course, I chose to do create an
interactive Polygon triangulation demo (for X-Monotone Polygons only).  It was
meant to be used as a teaching tool.

The project is done with Dart. With the `dart2js` you can compile it to
JavaScript.  Then open `triangulate.html` in any web browser and enjoy.  If you
want to draw larger Polygons, look for the `<canvas>` tag in the HTML file and
alter it's `width` and `height` properties.  You might need to tweak the CSS a
little too to make it look nice.

If you're interested in how the algorithm works, look at the function 
`triangulateXMontonePolygon()` in `geometry.dart`.  There's a little extra
"stepping code," in there; just ignore it.

All the files contained here fall under the GNU GPL v3 License, see the file
`LICENSE` for more info.

