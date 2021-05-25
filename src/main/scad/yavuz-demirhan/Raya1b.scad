include <puzzlecad.scad>

box_puzzle_scale = 15;
box_puzzle_border = 6;
$burr_inset = 0.125; 

interior_dim = [4, 3, 2] * box_puzzle_scale;

dim = interior_dim + [box_puzzle_border * 2, box_puzzle_border * 2, box_puzzle_border];


mid = box_puzzle_border / 2 + 0.5;
far = dim.y - mid;
far2 = dim.x - mid;

*pieces();
box();
cap();

module pieces() {
    burr_plate([
    ["xx|xx"],["xx|xx"],["xx|xx"],  //piece A-3 copies
    ["x..|xxx"],["x..|xxx"],["x..|xxx"], //piece B-3 copies
    ], $burr_scale = box_puzzle_scale,$plate_width = 150,$burr_bevel = 1.0);
}

module box() {
    
    difference() {
        beveled_cube(dim);
        translate([box_puzzle_border - $burr_inset, box_puzzle_border - $burr_inset, box_puzzle_border- $burr_inset])
        cube([
            interior_dim.x + $burr_inset * 2,
            interior_dim.y + $burr_inset * 2,
            interior_dim.z + $burr_inset * 2]);
    }
    translate([mid, mid, dim.z]) cylinder(r = 2.2, h = 2, $fn = 32);
    translate([mid, far, dim.z]) cylinder(r = 2.2, h = 2, $fn = 32);
    translate([far2, far, dim.z]) cylinder(r = 2.2, h = 2, $fn = 32);
    translate([far2, mid, dim.z]) cylinder(r = 2.2, h = 2, $fn = 32);    
    
}

module cap() {
    render(convexity = 2)
    translate([0,0,dim.z])
    difference() {
        beveled_cube([dim.x, dim.y, box_puzzle_border]);
  //first cutout removal      
        translate([box_puzzle_border+.5*box_puzzle_scale-$burr_inset,box_puzzle_border - $burr_inset,0])        
        cube([box_puzzle_scale*3+ $burr_inset * 2,box_puzzle_scale*2 + $burr_inset * 2,,box_puzzle_border]);
  // second cutout removal     
        translate([box_puzzle_border+1.5*box_puzzle_scale-$burr_inset,box_puzzle_border-$burr_inset +2*box_puzzle_scale,0])
     cube([box_puzzle_scale+2*$burr_inset,box_puzzle_scale+2*$burr_inset,box_puzzle_border]);
  
  // now remove the pins       
        translate([mid, mid, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([mid, far, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([far2, far, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([far2, mid, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
    }// end of main difference


}
