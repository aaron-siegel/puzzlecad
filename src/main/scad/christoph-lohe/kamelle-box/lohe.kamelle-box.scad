/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Christoph Lohe
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

$burr_scale = 17;
$burr_inset = 0.15;
$burr_bevel = 1;
$unit_beveled = true;
box_puzzle_border = 6;

*pieces();
*box();
*cap();

module pieces() {
    
    burr_plate([
        ["xx.|xxx", "x..|..x"],
        ["x..|xxx"],
        [".x.|xxx"]
    ], $plate_width = 150);
    
}

dim = [
    $burr_scale * 3 + box_puzzle_border * 2,
    $burr_scale * 2 + box_puzzle_border * 2,
    $burr_scale * 3 + box_puzzle_border + $burr_inset
];
mid = box_puzzle_border / 2;

module box() {
    
    difference() {
        
        beveled_cube(dim, $burr_bevel = 0.5);
        
        translate([box_puzzle_border - $burr_inset, box_puzzle_border - $burr_inset, box_puzzle_border - $burr_inset])
        cube([
            $burr_scale * 3 + $burr_inset * 2,
            $burr_scale * 2 + $burr_inset * 2,
            $burr_scale * 3 + $burr_inset * 2 + 0.001
        ]);
        
        translate([box_puzzle_border + $burr_scale - $burr_inset, box_puzzle_border - $burr_inset, -0.001])
        cube([$burr_scale + $burr_inset * 2, $burr_scale * 2 + $burr_inset * 2, box_puzzle_border + 0.002]);
        
    }
    
    translate([mid + 0.5, mid + 0.5, dim.z]) cylinder(r = 1.8, h = 2, $fn = 32);
    translate([mid + 0.5, dim.y - mid - 0.5, dim.z]) cylinder(r = 1.8, h = 2, $fn = 32);
    translate([$burr_scale * 2 + mid - 0.5, mid, dim.z]) cylinder(r = 1.8, h = 2, $fn = 32);
    translate([$burr_scale + mid - 0.5, dim.y - mid, dim.z]) cylinder(r = 1.8, h = 2, $fn = 32);
    
}

module cap() {
    
    difference() {
        
        beveled_prism([
            [0, 0],
            [0, dim.y],
            [$burr_scale + box_puzzle_border - $burr_inset, dim.y],
            [$burr_scale + box_puzzle_border - $burr_inset, $burr_scale + box_puzzle_border + $burr_inset],
            [$burr_scale * 2 + box_puzzle_border - $burr_inset, $burr_scale + box_puzzle_border + $burr_inset],
            [$burr_scale * 2 + box_puzzle_border - $burr_inset, 0],
        ],
        height = box_puzzle_border, $burr_bevel = 0.5);
        
        translate([mid + 0.5, mid + 0.5, 0]) cylinder(r = 2, h = 2, $fn = 32);
        translate([mid + 0.5, dim.y - mid - 0.5, 0]) cylinder(r = 2, h = 2, $fn = 32);
        translate([$burr_scale * 2 + mid - 0.5, mid, 0]) cylinder(r = 2, h = 2, $fn = 32);
        translate([$burr_scale + mid - 0.5, dim.y - mid, 0]) cylinder(r = 2, h = 2, $fn = 32);
        
    }
    
}
