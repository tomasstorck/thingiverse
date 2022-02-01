// [mm] width of the tie wrap
dx_tie = 5;
// [mm] height of the tie wrap
dy_tie = 2;
// [mm] Inner diameter of the ring holding the torch. Subtract 1 mm from the diameter of your torch for a good grid.
diameter_ring = 23;
// [mm] Thickness of the ring holding the torch
thickness_ring = 3;
// [mm] diameter of the handlebar
diameter_handlebar = 30;

// Number of faces
$fn = 128;
// [mm] size of the entire holder, Z-direction
dz = 23;
// [degrees] 360 is completely round, 180 is a half circle. Increase for better grip, but harder to insert
angle = 220;
// [mm] size of the cube, X-direction, that connects the ring holding the torch and the ring holding the handlebar
dx_cube = 17;
// [mm] size of the cube, Y-direction
dy_cube = 10;
// [mm] overlap of the handlebar cut-out with the cube
overlap_handlebar = 4;
// [degrees] orientation of the handlebar w.r.t. the torch. Always 0 or 90 degrees.
rotate_handlebar = 90;
// [mm] how far apart should the two tie wraps be placed
separation_tie = 4;
// [mm] distance between the tie wrap and the handlebar edge
offset_y_tie = 5;

module ring(diameter, height, thickness, angle=360) {
    // diameter = inner diameter
    // centre placed on origin
    rotate([0, 0, (180-angle)/2+180])
        rotate_extrude(angle=angle)
            translate([diameter/2, -height/2, 0])
                square([thickness, height]);
}

// Subtract (handlebar + tie wraps) cut-outs from (ring + cube)
difference() {  // Comment out this line and the closing brace for debugging, will show the geometry without subtracting parts
    y_cube = -dy_cube+thickness_ring;
    union() {
        // Cube onto which ring is placed
        translate([-dx_cube/2, y_cube, -dz/2])
            cube([dx_cube, dy_cube, dz]);
        // Ring to hold the torch
        translate([0, diameter_ring/2+thickness_ring, 0])
            ring(diameter=diameter_ring, height=dz, thickness=thickness_ring, angle=angle);
    }
    // Handlebar + tie wraps cut-outs
    // Names (x, y, z) are assuming rotation = 0
    rotate([0, rotate_handlebar, 0]) {
        length_cutout = diameter_ring + dz;
        // Handlebar
        y_handlebar = y_cube-diameter_handlebar/2+overlap_handlebar;
        translate([0, y_handlebar, -(length_cutout)/2])
            cylinder(h=length_cutout, d=diameter_handlebar);
        // Tie wraps
        diameter_tie = diameter_handlebar + offset_y_tie;
        translate([0, y_handlebar, -(separation_tie/2 + dx_tie/2)])
            ring(diameter=diameter_tie, height=dx_tie, thickness=dy_tie);
        translate([0, y_handlebar, separation_tie/2 + dx_tie/2])
            ring(diameter=diameter_tie, height=dx_tie, thickness=dy_tie);
    }
}