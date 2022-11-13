$fn=16;
finger_rings = [  // Finger = the bottom half of the pick
    [13, 5],  // [radius, height]. For radius, use the widest part of your finger.
    [12, 5],
    [11, 5],
];
thickness = 3;
aspect_ratio = 0.75;  // 
nail_rings = [  // Nail = the top part of the pick
    [11, 7],
    [10, 7],
];
nail_width_bottom = 20;
nail_width_top = 15;  // Do not go below thickness/2 for best result

// Determine dependent dimensions of model
nail_height = calculate_rings_height(nail_rings, len(nail_rings)-1);
total_height = calculate_rings_height(finger_rings, len(finger_rings)-1) + nail_height;
max_radius = calculate_rings_max_radius(finger_rings, len(finger_rings)-1);

// Warn if user stuffed up dimensions
if (finger_rings[len(finger_rings)-1][0] != nail_rings[0][0])
    echo("WARNING: finger and nail are not aligned, model will be broken");

function calculate_ring_z(finger_rings, i1) =  //  Use recursive functions because OpenSCAD calculates variables at runtime
    (i1 == 0 ? 0 : finger_rings[i1-1][1] + calculate_ring_z(finger_rings, i1-1));

function calculate_rings_height(finger_rings, i1) =
    (i1 == 0 ? finger_rings[0][1] : finger_rings[i1][1] + calculate_rings_height(finger_rings, i1-1));

function calculate_rings_max_radius(finger_rings, i1) = 
    (i1 == 0 ? finger_rings[0][0] : max(finger_rings[i1][0], finger_rings[i1-1][0]));

module create_hull(finger_rings) {
    hull() {
        for(i = [0 : len(finger_rings)-1]) {
            ring = finger_rings[i];
            r = ring[0];
            h = ring[1];
            z = calculate_ring_z(finger_rings, i);
            translate([0, 0, z])
                cylinder(r=r, h=h);
        }
    }
}

module create_rings(rings, thickness) {
    outer_rings = [for (i = [0:len(rings)-1]) [rings[i][0]+thickness, rings[i][1]]];
    difference() {
        create_hull(outer_rings);
        create_hull(rings);
    }
}

module create_nail(z, r) {
    nail_height = calculate_rings_height(nail_rings, len(nail_rings)-1);
    nail_y_offset = nail_rings[len(nail_rings)-1][0] + thickness/2;
    translate([0, 0, z]) {
        intersection() {
            create_rings(nail_rings, thickness=thickness);
            translate([0, nail_y_offset, 0])
                cylinder(h=nail_height, r1=nail_width_bottom/2, r2=nail_width_top/2);
        }
    }
}

module create_pick(finger_rings) {
    union() {
        create_rings(finger_rings, thickness=thickness);
        r = finger_rings[len(finger_rings)-1][0];
        z = calculate_rings_height(finger_rings, len(finger_rings)-1);
        create_nail(z, r);
    }
}

// Resize depth to aspect_ratio*width
resize([2*max_radius, 2*max_radius*aspect_ratio, total_height])
    create_pick(finger_rings);