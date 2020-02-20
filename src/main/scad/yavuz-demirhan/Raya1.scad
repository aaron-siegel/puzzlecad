include <puzzlecad2.scad>

box_puzzle_scale = 15;
box_puzzle_border = 6;
$burr_inset = 0.16; 
long = box_puzzle_scale * 4; // voxels long
wide = box_puzzle_scale * 3; // voxels wide
high = box_puzzle_scale * 2; // voxels high

dimlong = long + box_puzzle_border * 2;
dimwide = wide + box_puzzle_border * 2;
height = high + box_puzzle_border;

mid = box_puzzle_border / 2 + 0.5;
far = dimlong - mid;
far2 = dimwide - mid;

pieces();
*box();
*cap();

module pieces() {
    burr_plate([
    ["xx|xx"],  //piece A
    ["x..|xxx"],//piece B
    ], $burr_scale = box_puzzle_scale,$plate_width = 150,$burr_bevel = 1.0);
}

module box() {
    
    difference() {
        beveled_cube([dimwide, dimlong, height]);
        translate([box_puzzle_border - $burr_inset, box_puzzle_border - $burr_inset, box_puzzle_border- $burr_inset])
        cube([
            wide + $burr_inset * 2,
            long + $burr_inset * 2,
            high + $burr_inset * 1]);
    }
    translate([mid, mid, height]) cylinder(r = 2.2, h = 2, $fn = 32);
    translate([mid, far, height]) cylinder(r = 2.2, h = 2, $fn = 32);
    translate([far2, far, height]) cylinder(r = 2.2, h = 2, $fn = 32);
    translate([far2, mid, height]) cylinder(r = 2.2, h = 2, $fn = 32);    
    
}

module cap() {
    render(convexity = 2)
    translate([0,0,height])
    difference() {
        beveled_cube([dimwide, dimlong, box_puzzle_border]);
  //first cutout removal      
        translate([box_puzzle_border - $burr_inset,box_puzzle_border+.5*box_puzzle_scale-$burr_inset,0])        
        cube([box_puzzle_scale*2 + $burr_inset * 2,box_puzzle_scale*3+ $burr_inset * 2,box_puzzle_border]);
  // second cutout removal     
        translate([box_puzzle_border-$burr_inset +2*box_puzzle_scale,box_puzzle_border+1.5*box_puzzle_scale-$burr_inset,0])
     cube([box_puzzle_scale+2*$burr_inset,box_puzzle_scale+2*$burr_inset,box_puzzle_border]);
  
  // now remove the pins       
        translate([mid, mid, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([mid, far, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([far2, far, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
        translate([far2, mid, 0]) cylinder(r = 2.4, h = 2.15, $fn = 32);
    }// end of main difference


}
