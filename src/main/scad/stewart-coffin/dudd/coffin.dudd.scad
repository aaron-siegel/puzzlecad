include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_outer_x_bevel = 1.75;
$use_alternate_diag_inset_hack = true;

*piece_1();
*piece_2();

module piece_1() {
    
    burr_piece([
        "x....x|xxxxxx",
        "x....x|xxx{components={z-,y-,x-z-,x-y-,x+z-,x+y-}}x{components={z-,y-,x-z-,x-y-,x+z-,x+y-}}xx"
    ]);
    
}

module piece_2() {
    
    burr_piece([
        "x....x|xxx{components={z+,y-,x-z+,x-y-,x+z+,x+y-}}x{components={z+,y-,x-z+,x-y-,x+z+,x+y-}}xx",
        "x....x|xxx{components={z-,y-,x-z-,x-y-,x+z-,x+y-}}x{components={z-,y-,x-z-,x-y-,x+z-,x+y-}}xx"
    ]);
    
}
