// Created by Tomas Storck (github.com/tomasstorck)
// Licensed via Creative Commons Attribution-ShareALike license (CC BY-SA)

// Independent parameters. Set these as you will.
r_long = 10;                // [mm] Half of centre-centre distance between hexagons == length of side == distance from centre to furthest corner.
thickness_hexagon = 1.0;    // [mm] How tall (Z) each hexagon is.
thickness_connection = 0.7; // [mm] Of each triangle connection between two hexagons.
thickness_wall = 1.5;       // [mm] Of each enclosing side of the print.
width_connection = 1;       // [mm] Base of triangle.
width_wall = 2;             // [mm] Broadness (X or Y).
spacing = 0.8;              // [mm] Spacing between hexagons.
n_x = 13;                   // [-] Number of hexagons in the X direction.
n_y = 12;                   // [-]


// Dependent parameters. You should not have to modify these.
r_short = cos(30)*r_long;  // [mm] Shortest length from centre of hexagon to side.
height = get_y(0, n_y-1) + spacing;  // Limit height to a whole number of hexagons. Add 0.5 extra spacing at top and bottom to make use of the entire spacing touching the wall.
width = get_x(n_x) + r_long + spacing;
echo("width = ", width, ", height = ", height);  // Prints the width and height of your print, excluding walls.

// Define how to draw a triangle using a low-face count cylinder
// Draws a cylinder with three faces on the side centred on the y-axis, with the bottom touching the x-axis
// Base width = height = depth = 1
module triangle() {
    scale([2/3, 1, 2/3])
    translate([0, 0, 0.5])
    rotate([0, -90, -90])
    cylinder(1, 1, 1, $fn=3);
}
// Define how to draw a hexagon
module hexagon() {
    cylinder(r=r_long-spacing, h=thickness_hexagon, $fn=6);
}

// Define x and y of center of hexagon with index i on the x-axis and j on the y-axis
function get_x(i) = width_wall - 0.5*r_long + 0.5*spacing + i*1.5*r_long;
function get_y(i, j) = width_wall + 0.5*spacing + j*2*r_short - (i % 2 == 0 ? 0 : r_short);

// Create wall around hexagons
// [0, 0] to [x, 0]
scale([width+width_wall, width_wall, thickness_wall])
cube(1);
// [x, 0] to [x, y]
translate([width, 0, 0])
scale([width_wall, height+width_wall, thickness_wall])
cube(1);
// [x, y] to [0, y]
translate([0, height, 0])
scale([width+width_wall, width_wall, thickness_wall])
cube(1);
// [0, y] to [0, 0]
scale([width_wall, height+width_wall, thickness_wall])
cube(1);

intersection() {
    // Create a union of all parts except walls
    union() {
        // Connections: top-bottom
        for (i = [0 : n_x+1]) {
            x = get_x(i);
            translate([x, -0.5*spacing, 0])
            scale([width_connection, height+spacing, thickness_connection])
            triangle();
        }
        
        // Connections: diagonal, up
        for (j = [-(n_y+n_x):2:n_y+n_x]) {
            x = get_x(j);
            y = get_y(j, 0);
            translate([x, y ,0])
            rotate(-60)
            scale([width_connection, height/cos(60), thickness_connection])
            triangle();
        }

        // Connections: diagonal, down
        for (j = [0:2:2*(n_y+n_x)]) {
            x = get_x(j);
            y = get_y(j, 0);
            translate([x, y ,0])
            rotate(60)
            scale([width_connection, height/cos(60), thickness_connection])
            triangle();
        }

        // Hexagons
        for (i = [0 : n_x+1]) {
            x = get_x(i);
            for (j = [0 : n_y]) {
                y = get_y(i, j);
                // Hexagon
                translate([x, y, 0])
                hexagon();
            }
        }
    }

    // Box to cut away everything outside of range of union above
    scale([width, height, max(thickness_hexagon, thickness_connection)])
    cube(1);
}