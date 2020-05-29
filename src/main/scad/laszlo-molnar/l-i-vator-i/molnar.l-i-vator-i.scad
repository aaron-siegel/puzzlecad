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

$burr_inset = 0.15;     // Use 0.125 for a tighter fit
$burr_bevel = 1;
$unit_beveled = true;
$burr_scale = 17;

box_puzzle_border = 6;

// Uncomment one of the following lines to render that component.

*box();
*pieces();
*cap();

dim = $burr_scale * 3 + box_puzzle_border * 2 + $burr_inset * 2;
height = $burr_scale * 3 + box_puzzle_border + $burr_inset * 2;

mid = box_puzzle_border / 2 + 0.5;
far = dim - mid;

module box() {
    render(convexity = 2)
    difference() {
        beveled_cube([dim, dim, height], $burr_bevel = 0.5);
        translate([box_puzzle_border, box_puzzle_border, box_puzzle_border])
        cube([
            $burr_scale * 3 + $burr_inset * 2,
            $burr_scale * 3 + $burr_inset * 2,
            $burr_scale * 4
        ]);
     }
     
     translate([0, 0, height])
     connector(1.8, 2.0);
}

module pieces() {
    burr_plate([
        ["x.|x{connect=fz+y-,clabel=A}."],
        ["x{connect=mz+y-,clabel=A}xx|..x"],
        ["xx{connect=mz+y-,clabel=B}"],
        ["xx|x.","..|x.","..|x{connect=fx-z+,clabel=B}."],
        ["xxx|..x", "x..|..."],
        ["xxx|..x"],
        [".x|xx"],
        ["xx"]
    ], $plate_width = 160);
}

module cap() {
    render(convexity = 2)
    difference() {
        beveled_cube([dim, dim, box_puzzle_border], $burr_bevel = 0.5);
        translate([box_puzzle_border, box_puzzle_border, 
        -0.01
        ])
        
        cube([
            $burr_scale * 2 + 2 * $burr_inset,
            $burr_scale * 2 + 2 * $burr_inset,
            box_puzzle_border * 2
        ]);
        
        translate([
            box_puzzle_border + $burr_scale - $burr_inset, 
            box_puzzle_border + $burr_scale - $burr_inset,
           -0.01
        ])
      
        cube([
            $burr_scale * 2 + 2 * $burr_inset,
            $burr_scale * 2 + 2 * $burr_inset,
            box_puzzle_border * 2
        ]);

        connector(2.0, 2.15);
    }
}

module connector(radius, height) {
    translate([mid, mid, 0]) cylinder(r = radius, h = height, $fn = 32);
    translate([mid, far, 0]) cylinder(r = radius, h = height, $fn = 32);
    translate([far, far, 0]) cylinder(r = radius, h = height, $fn = 32);
    translate([far, mid, 0]) cylinder(r = radius, h = height, $fn = 32);
}
