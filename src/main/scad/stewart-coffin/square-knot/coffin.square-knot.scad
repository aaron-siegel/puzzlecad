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

$burr_scale = 8;
$burr_inset = 0.07;
$burr_bevel = 0.5;
outer_width = 2;

*piece();
*piece_reverse_left();
*piece_reverse_right();

module piece() {

    burr_piece(generalized_altekruse("dbd", outer_width));
    
}

module piece_reverse_left() {
    
    burr_piece(generalized_altekruse("bdf", outer_width));
    
}

module piece_reverse_right() {
    
    burr_piece(generalized_altekruse("fdb", outer_width));
    
}
