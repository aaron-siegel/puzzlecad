/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Yavuz Demirhan
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.0");

box_puzzle_scale = 17;
box_puzzle_border = 6;
$burr_inset = 0.125;

dim = box_puzzle_scale * 3 + box_puzzle_border * 2;
height = box_puzzle_scale * 2 + box_puzzle_border + $burr_inset * 2;

mid = box_puzzle_border / 2 + 0.5;
far = dim - mid;

*pieces_color_1();
*pieces_color_2();
*box();
*cap();

module pieces_color_1() {
    burr_plate([
        ["x|x|x"],
        ["x|x|x"],
        ["x|x{connect=fz+y+,clabel=A}"],
        ["x{connect=mz+y+,clabel=B}"]
    ], $burr_scale = box_puzzle_scale, $plate_width = 160);
}

module pieces_color_2() {
    burr_plate([
        ["x|x{connect=fz+y+,clabel=B}"],
        ["x{connect=mz+y+,clabel=A}"],
        ["x.|xx"],
        ["x.|xx"]
    ], $burr_scale = box_puzzle_scale, $plate_width = 160);
}

module box() {
    
    difference() {
        beveled_cube([dim, dim, height]);
        translate([box_puzzle_border - $burr_inset, box_puzzle_border - $burr_inset, box_puzzle_border])
        cube([
            box_puzzle_scale * 3 + $burr_inset * 2,
            box_puzzle_scale * 3 + $burr_inset * 2,
            box_puzzle_scale * 2 + $burr_inset * 2 + 0.001
        ]);
    }
    translate([mid, mid, height]) cylinder(r = 2.2, h = 2, $fn = 32);
    translate([mid, far, height]) cylinder(r = 2.2, h = 2, $fn = 32);
    translate([far, far, height]) cylinder(r = 2.2, h = 2, $fn = 32);
    translate([far, mid, height]) cylinder(r = 2.2, h = 2, $fn = 32);    
    
}

module cap() {
    
    render(convexity = 2)
    difference() {
        beveled_cube([dim, dim, box_puzzle_border]);
        translate([dim/2, dim/2, box_puzzle_border/2])
        cube([
            box_puzzle_scale * 3 + $burr_inset * 2,
            box_puzzle_scale + $burr_inset * 2,
            box_puzzle_border
        ], center=true);
        translate([dim/2, dim/2, box_puzzle_border/2])
        cube([
            box_puzzle_scale * 2 + $burr_inset * 2,
            box_puzzle_scale * 2 + $burr_inset * 2,
            box_puzzle_border
        ], center=true);
        translate([mid, mid, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([mid, far, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([far, far, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([far, mid, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
    }
    
}
