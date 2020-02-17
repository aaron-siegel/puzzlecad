include <puzzlecad.scad>

box_puzzle_border = 6;
box_puzzle_top_inset = 1;

$burr_inset = 0.12;
$burr_bevel = 1;
$unit_beveled = true;
$burr_scale = 16;

dim = $burr_scale * 3 + box_puzzle_border * 2 + $burr_inset * 2;
hight = $burr_scale * 3 + box_puzzle_border + box_puzzle_top_inset + $burr_inset;

box();
*piece_x4();
*piece_x1();
*piece_triangle();

module box() {
    render(convexity = 2)
    difference() {
        beveled_cube([dim, dim, hight]);
        translate([box_puzzle_border, box_puzzle_border, box_puzzle_border])
        cube([
            $burr_scale * 3 + $burr_inset * 2,
            $burr_scale * 3 + $burr_inset * 2,
            $burr_scale * 4
        ]);
         
        translate([dim / 2, box_puzzle_border, hight - $burr_scale / 2])
        rotate(a=90, v=[1, 0, 0])
        cylinder(r = 2.2, h = 2.2, $fn = 32);
     }
}

module piece_x4() {
    render(convexity = 2)
        burr_plate([
        ["xxx|x..", "...|x.."]
    ]);
}

module piece_x1() {
    render(convexity = 2)
    burr_plate([
        ["xxx{components={x-,y-,z+y-,z+x-,z-y-,z-x-}}|x..", "...|x.."]
    ]);
}

module piece_triangle() {
   render(convexity = 2)
   burr_plate([
       ["x{components={x-,y-,z+y-,z+x-,z-y-,z-x-}}"]
   ]);
   translate([$burr_scale / 2, 0, $burr_scale / 2])
   rotate(a=90, v=[1, 0, 0])
   cylinder(r = 2.0, h = 2.0, $fn = 32);
}
