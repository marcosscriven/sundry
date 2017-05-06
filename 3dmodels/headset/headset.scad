// Constant for use in fixing z fight
ZFIGHT=0.01;

// Clamps x between lower and upper values
function clamp(x, lower, upper) =
    min(max(x, lower), upper);

// Generates an anti-clockwise rectangle with n points on perimeter, first point at origin
function generate_rectangle(width, length, n) =
    // Points per side is one quarter of n
    let(pps = n / 4)
    1 / pps * [ for (i = [0:n-1])
        [
            // This works by summing the steps taken in the x or y direction
            (clamp(i - pps * 0, 0, pps) - clamp(i - pps * 2, 0, pps)) * width,
            (clamp(i - pps * 1, 0, pps) - clamp(i - pps * 3, 0, pps)) * length,
            0
        ]
    ];

// Generates an anti-clockwise circle with n points on perimeter, centered on origin
function generate_circle(radius, start_angle, n) =
    radius * [ for (i = [0:n-1], angle = start_angle - 360 * i / n)
        [sin(angle), cos(angle), 0]
    ];

// Translate x by vector t (without faffing with homongenous matricies)
function simple_translate(x, t) =
    [ for (i = x) i + t ];

// Create a volume from two polys with equal number of points
// Both polys MUST be in anti-clockwise order to orient correctly
module VolumeFromPolys(p1, p2){
    n = len(p1);
    all_points = concat(p1, p2);
    all_faces = concat(

        // p1 poly
        [[ for (i = [0:n-1]) i ]],

        // side triangles (bases on p1)
        [ for (i = [0:n-1]) [ (i + 1) % n, i, i + n ] ],

        // side triangles (bases on p2)
        [ for (i = [0:n-1]) [ i + n, ((i + 1) % n) + n , (i + 1) % n ] ],

        // p2 poly
        // traverse these points in opposite order to orient face outwards
        [[for (i = [0:n-1]) 2 * n - i - 1 ]]
        );

    // echo(all_points);
    // echo(all_faces);

    polyhedron(points = all_points, faces = all_faces);
}

module AngledEdge(length, size, rot) {
    // 1.73 gives a 30 degree angle
    rotate([0,0,rot])
        linear_extrude(height = length)
            polygon(points=size*[[0,0],[1,0],[0,1.73]]);
}

// Make a solid cone that starts with a rectangular base, and ends in a circle
module RectangleToCircleCone(width, length, radius, height, offset) {
    n = 32 * 4;
    start_angle = 220;

    rectangle_points = simple_translate(
        generate_rectangle(width, length, n), [-width/2, -length/2, 0]
    );
    circle_points = simple_translate(
        generate_circle(radius, start_angle, n),[offset, 0, height]
    );

    VolumeFromPolys(rectangle_points, circle_points);
}

// Viewing cone to view one half of the screen
module EyePiece(width, length, lens_diameter, height, thickness, offset) {

    // Main cone
    difference() {
        RectangleToCircleCone(
            width + 2 * thickness,
            length + 2 * thickness,
            lens_diameter / 2 + thickness,
            height,
            offset
        );
        translate([0, 0, -ZFIGHT])
            RectangleToCircleCone(
                width,
                length,
                lens_diameter / 2,
                height + 2 * ZFIGHT,
                offset
            );
    }

    // Lens holder
    $fn=128;
    lip_thickness = 2;  // Overhang to support lens
    eyepiece_height = 5;
    translate([offset, 0, height])
    difference() {
        cylinder(h = eyepiece_height, d = lens_diameter + 2 * thickness);
        translate([0, 0, thickness])
            cylinder(h = eyepiece_height + ZFIGHT, d = lens_diameter);
        translate([0, 0, -ZFIGHT])
            cylinder(h = eyepiece_height + 2 * ZFIGHT, d = lens_diameter - lip_thickness);
    }
}

module MagnetSwitch() {

    thickness = 1;
    magnet_diameter = 20 + 1.5;
    magnet_depth = 5.5;
    washer_diameter = 20 + 1.5;
    washer_depth = 2;

    block_width = magnet_diameter + 2 * thickness;
    block_length = 1.5 * magnet_diameter + 2 * thickness;
    block_depth = magnet_depth + washer_depth + thickness;

    difference() {
        cube([block_width, block_length, block_depth]);

        // Sliding space for washer
        $fn = 128;
        translate([block_width/2, washer_diameter/2 + thickness, block_depth - washer_depth + ZFIGHT])
            cylinder(d=washer_diameter, h=washer_depth);
        translate([block_width/2, block_length - washer_diameter/2 - thickness, block_depth - washer_depth + ZFIGHT])
            cylinder(d=washer_diameter, h=washer_depth);
        translate([block_width/2, block_length/2, block_depth - washer_depth/2 + ZFIGHT])
            cube([washer_diameter, 0.5 * washer_diameter, washer_depth], center=true);

        // Holding space for magnet_depth
        translate([block_width/2, magnet_diameter/2 + thickness, -ZFIGHT])
          cylinder(d=magnet_diameter, h=magnet_depth);
    }

}

module Viewer(phone_length, phone_width, screen_length, screen_width, height, thickness) {

    // 'width' of view is half the length of screen, minus half thickness (can overlap)
    view_width = screen_length / 2 - thickness/2;

    // 'length' of the view is the width of the whole screen
    view_length = screen_width;

    length = phone_length + 2 * thickness;
    width = phone_width + 2 * thickness;

    // Actual + tolerance
    lens_diameter = 25 + 1;

    // Offset of eyepieces to account for required distance between eyes
    pupillary_distance = 63;
    offset = (pupillary_distance - view_width - thickness) / 2 ;

    left_center  = [length / 2 - view_width / 2 - thickness / 2, width / 2, 0];
    right_center = [length / 2 + view_width / 2 + thickness / 2, width / 2 ,0];

    // Main base
    difference() {
        cube([length, width, thickness]);

        // Square holes for eyepieces
        translate(left_center-[0,0,-0.02])
            cube([view_width, view_length, thickness+2], center=true);
        translate(right_center-[0,0,-0.02])
            cube([view_width, view_length, thickness+2], center=true);
    }

    // Two eyepieces
    translate(left_center)
        EyePiece(view_width, view_length, lens_diameter, height, thickness, -offset);

    translate(right_center)
        EyePiece(view_width, view_length, lens_diameter, height, thickness, offset);

    // Add the magnet switch
    translate([-3.8, width/2 - 15, 0])
        //rotate([0, -90, 0])
            MagnetSwitch();
}

module Tray(phone_length, phone_width, phone_depth, thickness) {

    tray_length = phone_length + 2 * thickness;
    tray_width = phone_width + 2 * thickness;
    tray_depth = phone_depth + thickness;

    difference() {
        difference() {
            cube([tray_length, tray_width, tray_depth]);
            translate([thickness, -ZFIGHT, thickness])
                cube([phone_length, phone_width + thickness, phone_depth + ZFIGHT]);
        }

        // Cut some out of the base to save material / print time
        cut_out_margin = 3.5;
        translate([thickness + cut_out_margin , thickness + cut_out_margin, -ZFIGHT])
            cube([phone_length - 2 * cut_out_margin, phone_width - 2 * cut_out_margin, thickness + 2 * ZFIGHT]);

        // Cut a hole for the headphone jack
        $fn = 32;
        headphone_hole_radius = 3.5;
        distance_from_edge = 12.5;
        translate([-ZFIGHT, phone_width + thickness - distance_from_edge, headphone_hole_radius + thickness])
            rotate([0,90,0])
                cylinder(r=headphone_hole_radius, h=thickness + 2 * ZFIGHT);
    }
}

// iPhone 6 measurements (actual + empirical fudge)
phone_length = 138.1 + 1.4;
phone_width = 67.0 + 1.0;
phone_depth = 6.9 + 0.6;
screen_length = 104;
screen_width = 58;

// Settings
thickness = 2;
height = 42;

//Tray(phone_length, phone_width, phone_depth, thickness);
Viewer(phone_length, phone_width, screen_length, screen_width, height, thickness);
