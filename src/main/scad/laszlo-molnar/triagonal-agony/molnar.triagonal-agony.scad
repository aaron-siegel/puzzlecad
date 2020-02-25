include <puzzlecad.scad>

box_puzzle_border = 6;

$burr_inset = 0.125;
$burr_bevel = 1;
$unit_beveled = true;
$burr_scale = 17;

pin_height = 1.0;
pin_r = 1.6;
pin_hole_inset = 0.2;

dim = $burr_scale * 3 + box_puzzle_border * 2 + $burr_inset * 2;
    
*box();
*pieces();
*cap();

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
module pieces() {
    burr_plate([
        ["xxx|x.."],
        ["..x|xxx", "...|.x."],
        ["xx|.x", "..|.x"],
        ["x.|xx|.x", "..|..|.x"],
        ["xx|.x", ".x|.."],
        ["xxx|..x", "..x"]
    ], $plate_width = 160);
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
    
   beveled_prism([[0, 0], [0, dim - 2 * box_puzzle_border], [box_puzzle_border, dim - 2 * box_puzzle_border], [dim - box_puzzle_border, 0]], height = box_puzzle_border);
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