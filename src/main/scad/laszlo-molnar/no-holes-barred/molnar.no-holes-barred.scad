include <puzzlecad.scad>

$burr_inset = 0.125;
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
        beveled_cube([dim, dim, height + box_puzzle_top_inset]);
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
        ["xxx{components={x-,y-,z+y-,z+x-,z-y-,z-x-}}|x.."]
    ], $plate_width = 160);
}

module obstruction() {
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
