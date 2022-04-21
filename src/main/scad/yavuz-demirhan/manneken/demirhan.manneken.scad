include <puzzlecad.scad>

box_puzzle_scale = 12.75;
box_puzzle_border = 6;
$burr_inset = 0.11;

dim = box_puzzle_scale * 4 + box_puzzle_border * 2;
height = box_puzzle_scale * 3 + box_puzzle_border + $burr_inset * 2;

mid = box_puzzle_border / 2 + 0.5;
far = dim - mid;

*piece();
*box();
*cap();

module piece() {
    burr_piece(["xxx|xxx", "x..|x.."], $burr_scale = box_puzzle_scale);
}

module box() {
    
    difference() {
        beveled_cube([dim, dim, height]);
        translate([box_puzzle_border - $burr_inset, box_puzzle_border - $burr_inset, box_puzzle_border])
        cube([
            box_puzzle_scale * 4 + $burr_inset * 2,
            box_puzzle_scale * 4 + $burr_inset * 2,
            box_puzzle_scale * 3 + $burr_inset * 2 + 0.001
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
            box_puzzle_scale * 4 + $burr_inset * 2,
            box_puzzle_scale * 2 + $burr_inset * 2,
            box_puzzle_border
        ], center=true);
        translate([dim/2 + box_puzzle_scale * 3/2, dim/2, box_puzzle_border/2])
        cube([
            box_puzzle_scale + $burr_inset * 2,
            box_puzzle_scale * 4 + $burr_inset * 2,
            box_puzzle_border
        ], center=true);
        translate([dim/2 - box_puzzle_scale / 2, dim/2, box_puzzle_border/2])
        cube([
            box_puzzle_scale + $burr_inset * 2,
            box_puzzle_scale * 4 + $burr_inset * 2,
            box_puzzle_border
        ], center=true);
        translate([mid, mid, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([mid, far, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([far, far, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([far, mid, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
    }
}
