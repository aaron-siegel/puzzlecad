/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) László Molnár
  3D model (c) Yu Chih Chang & Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

box_puzzle_border = 6;

$burr_inset = 0.15;     // Use 0.125 for a tighter fit
$burr_bevel = 1;
$unit_beveled = true;
$burr_scale = 17;

// Uncomment one of the following lines to render that component.

*pieces_version_1();
*pieces_version_2();
*pieces_version_3();
*box();
*cap();

pin_height = 1.0;
pin_r = 1.6;
pin_hole_inset = 0.2;

dim = $burr_scale * 3 + box_puzzle_border * 2 + $burr_inset * 2;

module pieces_version_1() {
    burr_plate([
        ["xxx|..x", "..x"],
        ["xxx|..x", "..x"],
        ["..x|xxx", "...|.x."],
        ["xx|.x", "..|.x"],
        ["xx|.x", "..|.x"],
        ["xxx|x.."]
    ], $plate_width = 160);
}

module pieces_version_2() {
    burr_plate([
        ["xxx|x.."],
        ["..x|xxx", "...|.x."],
        ["xx|.x", "..|.x"],
        ["x.|xx|.x", "..|..|.x"],
        ["xx|.x", ".x|.."],
        ["xxx|..x", "..x"]
    ], $plate_width = 160);
}

module pieces_version_3() {
    burr_plate([
        ["xxx|..x", "..x"],
        ["x..|xxx", "...|..x"],
        ["xxx|..x", "...|..x"],
        ["xxx|.x."],
        ["xx|.x", ".x|.."],
        ["xx|x.", "..|x."]
    ], $plate_width = 160);
}

module box() {
    render(convexity = 2)
    difference() {
        beveled_cube(dim, $burr_bevel = 0.5);
        translate([box_puzzle_border, box_puzzle_border, box_puzzle_border])
        cube([
            $burr_scale * 3 + $burr_inset * 2,
            $burr_scale * 4 + $burr_inset * 2,
            $burr_scale * 4 + $burr_inset * 2
        ]);
        

        translate([box_puzzle_border - pin_height - pin_hole_inset, box_puzzle_border * 2, dim - box_puzzle_border / 2])
        rotate([0, 90, 0])
        cylinder(r = pin_r + pin_hole_inset, h = box_puzzle_border, $fn = 32);
         
        translate([box_puzzle_border - pin_height - pin_hole_inset, dim - box_puzzle_border / 2, dim - box_puzzle_border / 2])
        rotate([0, 90, 0])
        cylinder(r = pin_r + pin_hole_inset, h = box_puzzle_border, $fn = 32);
  
        translate([dim - box_puzzle_border, dim - box_puzzle_border / 2, dim - box_puzzle_border / 2])
        rotate([0, 90, 0])
        cylinder(r = pin_r + pin_hole_inset, h = pin_height + pin_hole_inset, $fn = 32);
  
        translate([dim - box_puzzle_border, dim - box_puzzle_border / 2, 2 * box_puzzle_border])
        rotate([0, 90, 0])
        cylinder(r = pin_r + pin_hole_inset, h = pin_height + pin_hole_inset, $fn = 32); 
    }
}

module cap() {
    render(convexity = 2)
    rotate([0, -90, 0])
    union() {
        translate([0, box_puzzle_border, 0])
        rotate([90, 0, 0])
        triangle();

        rotate([0, 0, 90])
        translate([0, 0, dim - 2 * box_puzzle_border])
        mirror([0, 1, 1])
        triangle();
    }
}

module triangle() {
    translate([dim - 2 * box_puzzle_border, 0, box_puzzle_border / 2])
    rotate([90, 0, 0])
    cylinder(r = pin_r, h = pin_height, $fn = 32);
    
    translate([box_puzzle_border / 2, 0, box_puzzle_border / 2])
    rotate([90, 0, 0])
    cylinder(r = pin_r, h = pin_height, $fn = 32);
    
    beveled_prism([[0, 0], [0, dim - 2 * box_puzzle_border], [box_puzzle_border, dim - 2 * box_puzzle_border], [dim - box_puzzle_border, 0]], height = box_puzzle_border, $burr_bevel = 0.5);
}

// This module is used to sanity-check that the dimensions of the box components are correctly modeled.
// It should not be exported for printing.
module test_assembly() {
    box();
    translate([dim - box_puzzle_border, dim, dim])
    rotate([180, 0, 0])
    cap();
    translate([0, 80, 0])
    pieces();
}
