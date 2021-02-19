/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Stewart Coffin
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_outer_x_bevel = 1.75;
$burr_bevel = 0.5;
$burr_inset = 0.07;
$use_alternate_diag_inset_hack = true;

*piece_1();
*piece_2();

module piece_1() {
    
    burr_piece([
        "xxx{components={z+,y+,x+z+,x+y+,x-z+,x-y+}}x{components={z+,y+,x+z+,x+y+,x-z+,x-y+}}xx|xxxxxx",
        "x....x|x....x"
    ]);
    
}

module piece_2() {

    burr_piece([
        "xxx{components={z+,y+,x+z+,x+y+,x-z+,x-y+}}x{components={z+,y+,x+z+,x+y+,x-z+,x-y+}}xx|xxx{components={z+,y-,x+z+,x+y-,x-z+,x-y-}}x{components={z+,y-,x+z+,x+y-,x-z+,x-y-}}xx",
        "x....x|x....x"
    ]);
    
}
