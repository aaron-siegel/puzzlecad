include <puzzlecad.scad>

box_puzzle_border = 6;

$burr_inset = 0.125;
$burr_bevel = 1;
$unit_beveled = true;
$burr_scale = 17;

pin_height = 1.5;
pin_r = 1.6;
pin_hole_inset = 0.2;

dim = $burr_scale * 3 + box_puzzle_border * 2 + $burr_inset * 2;

*box();
*pieces();

module combinedSimulation() {
    // THIS IS ONLY FOR PREVIEW, SHOULD NOT BE EXPORTED
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
        ["xx", "x."],
        ["..x|xxx", "...|.x."],
        ["xxx|..x", "x.."],
        ["x.|xx", "x.", "x."],
        [".xx|xx."],
        [".x|xx", "..|.x", "..|.x"]
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
            translate([dim - 2*box_puzzle_border, -box_puzzle_border, box_puzzle_border])
            rotate([-90, 0, 0])
            cornor_piece();
        }

        translate([dim - box_puzzle_border * 3 / 2, -box_puzzle_border / 2, 0])
        cylinder(r = pin_r + pin_hole_inset, h = pin_height + pin_hole_inset, $fn = 32);
        
        translate([2 * box_puzzle_border, -box_puzzle_border / 2, 0])
        cylinder(r = pin_r + pin_hole_inset, h = pin_height + pin_hole_inset, $fn = 32);
    }
}


module cornor_piece() {
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
