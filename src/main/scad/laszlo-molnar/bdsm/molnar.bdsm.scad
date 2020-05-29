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

*box();
*pieces();

pin_height = 1.5;
pin_r = 1.6;
pin_hole_inset = 0.2;

dim = $burr_scale * 3 + box_puzzle_border * 2 + $burr_inset * 2;

module box () {
    box_piece();
    translate([-30, 50, 0])
    rotate([0, 0, 180])
    box_piece();
    
    translate([10, -10, 0])
    rotate([0, 0, 45])
    box_piece();
}

module pieces() {
    burr_plate([
        ["xx|x"],
        ["..x|xxx", "...|.x."],
        ["xxx|..x", "x.."],
        ["xxx|..x", "...|..x"],
        [".xx|xx."],
        ["xxx|..x", "..x"]
    ], $plate_width = 160);
}

module box_piece() {
    render(convexity = 2)
    rotate([0, -90, 0])
    union() {
        translate([0, box_puzzle_border, 0])
        rotate([90, 0, 0])
        triangle_large();

        rotate([0, 0, 90])
        translate([0, 0, dim - 2 * box_puzzle_border])
        mirror([0,1,1])
        triangle();
    }
}

module triangle_large() {
    difference() {
        union() {
            beveled_prism([
                [0, 0], 
                [0, dim - 2 * box_puzzle_border],
                [box_puzzle_border, dim - 2 * box_puzzle_border],
                [dim - box_puzzle_border, 0],
                [dim - box_puzzle_border, -box_puzzle_border],
                [box_puzzle_border, -box_puzzle_border], 
            ],
            height = box_puzzle_border);
            translate([dim - 2 * box_puzzle_border, -box_puzzle_border, box_puzzle_border])
            rotate([-90, 0, 0])
            corner_piece();
        }

        translate([dim - box_puzzle_border * 3 / 2, -box_puzzle_border / 2, 0])
        cylinder(r = pin_r + pin_hole_inset, h = pin_height + pin_hole_inset, $fn = 32);
        
        translate([2 * box_puzzle_border, -box_puzzle_border / 2, 0])
        cylinder(r = pin_r + pin_hole_inset, h = pin_height + pin_hole_inset, $fn = 32);
    }
}

module corner_piece() {
    beveled_prism([
      [0, 0],
      [0, box_puzzle_border],
      [box_puzzle_border, box_puzzle_border],
      [box_puzzle_border * 2, box_puzzle_border],
      [box_puzzle_border, 0],
    ],
    height = box_puzzle_border + 0.45);
 }

module triangle() {
   translate([box_puzzle_border * 3 / 2, 0, box_puzzle_border / 2])
   rotate([90, 0, 0])
   cylinder(r = pin_r, h = pin_height, $fn = 32);
    
   translate([dim - 2 * box_puzzle_border, 0, box_puzzle_border / 2])
   rotate([90, 0, 0])
   cylinder(r = pin_r, h = pin_height, $fn = 32);
    
   beveled_prism([[0, 0], [0, dim - 2 * box_puzzle_border], [box_puzzle_border, dim - 2 * box_puzzle_border], [dim - box_puzzle_border, 0]], height = box_puzzle_border);
}

// This module is used to sanity-check that the dimensions of the box components are correctly modeled.
// It should not be exported for printing.
module test_assembly() {
    box_piece();
    translate([box_puzzle_border, dim - box_puzzle_border, dim])
    rotate([0, -90, 0])
    rotate([0, 0, 90])
    box_piece();
    translate([-dim + box_puzzle_border, dim, box_puzzle_border])
    rotate([0, 0, -90])
    rotate([0, 90, 0])
    box_piece();

    translate([-120, -80, 0])
    pieces();
}
