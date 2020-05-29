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

$burr_inset = 0.15;     // Use 0.125 for a tighter fit.
$burr_bevel = 1;
$unit_beveled = true;
$burr_scale = 17;

box_puzzle_border = 6;
box_puzzle_top_inset = 1;

// Uncomment one of the following lines to render that component.

*box();
*pieces();
*obstruction();

dim = $burr_scale * 3 + box_puzzle_border * 2 + $burr_inset * 2;
height = $burr_scale * 3 + box_puzzle_border + $burr_inset;

module box() {
    render(convexity = 2)
    difference() {
        beveled_cube([dim, dim, height + box_puzzle_top_inset], $burr_bevel = 0.5);
        translate([box_puzzle_border, box_puzzle_border, box_puzzle_border])
        cube([
            $burr_scale * 3 + $burr_inset * 2,
            $burr_scale * 3 + $burr_inset * 2,
            $burr_scale * 4
        ]);
         
        translate([dim / 2 - $burr_scale / 4, box_puzzle_border, height - $burr_scale / 4])
        rotate(a=90, v=[1, 0, 0])
        cylinder(r = 2.2, h = 2.2, $fn = 32);
        
        translate([dim / 2 + $burr_scale / 4, box_puzzle_border, height - $burr_scale / 4])
        rotate(a=90, v=[1, 0, 0])
        cylinder(r = 2.2, h = 2.2, $fn = 32);
        
        translate([dim / 2, box_puzzle_border, height - $burr_scale * 3 / 4])
        rotate(a=90, v=[1, 0, 0])
        cylinder(r = 2.2, h = 2.2, $fn = 32);
     }
}

module pieces() {
    burr_plate([
        ["xxx|x..", "...|x.."],
        ["xxx|x..", "...|x.."],
        ["xxx|x..", "...|x.."],
        ["xxx|x..", "...|x.."],
        ["xxx{components={x-,y-,z+y-,z+x-,z-y-,z-x-}}|x..", "...|x.."]
    ], $plate_width = 160);
}

module obstruction() {
    
    rotate([0, 45, 0])
    translate([0, 0, $burr_scale])
    rotate([-90, 0, 0]) {
        
        burr_plate([
            ["x{components={x-,y-,z+y-,z+x-,z-y-,z-x-}}"]
        ]);
        
        translate([$burr_scale * 1 / 4, 0.001, $burr_scale * 1 / 4])
        rotate(a=90, v=[1, 0, 0])
        cylinder(r = 2.0, h = 2.0, $fn = 32);
        
        translate([$burr_scale *1 / 4, 0.001, $burr_scale * 3 / 4])
        rotate(a=90, v=[1, 0, 0])
        cylinder(r = 2.0, h = 2.0, $fn = 32);
        
        translate([$burr_scale *3 / 4, 0.001, $burr_scale * 1 / 2])
        rotate(a=90, v=[1, 0, 0])
        cylinder(r = 2.0, h = 2.0, $fn = 32);
        
    }
    
}
