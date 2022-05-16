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

$burr_scale = 6.5;

*piece_2_left();
*piece_2_right();
*piece_3();
*piece_4_left();
*piece_4_right();
*piece_5();

module piece_2_left() { piece(2, parity = 1); }
module piece_2_right() { piece(2, parity = 0); }
module piece_3() { piece(3); }
module piece_4_left() { piece(4, parity = 1); }
module piece_4_right() { piece(4, parity = 0); }
module piece_5() { piece(5); }

module piece(length, parity = 0) {

    spec_string = mkstring([ for (i = [0:length-1]) i % 2 == parity ? "d" : "b" ]);
    burr_piece(generalized_altekruse(spec_string, outer_width = 1));
    
}

module diagram_1() {
    
    piece_3();
    
}

module diagram_2() {
    
    piece_2_right();
    translate([0, -$burr_scale * 6, 0])
    piece_3();
    translate([0, -$burr_scale * 12, 0])
    piece_4_right();
    translate([0, -$burr_scale * 18, 0])
    piece_5();
    
}
