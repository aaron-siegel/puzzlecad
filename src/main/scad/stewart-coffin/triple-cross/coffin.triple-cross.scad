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

$burr_scale = 20;
$burr_inset = 0.11;
$burr_bevel = 1;

*piece();
*piece_length_4();
*piece_length_5();

module piece() {
    
    generalized_piece(3);
    
}

module piece_length_4() {
    
    generalized_piece(4);
    
}

module piece_length_5() {
    
    generalized_piece(5);
    
}

module generalized_piece(n) {

    spec = mkstring([
        for (i = [1:n])
        if (i % 2 == 1) "x{components={x-,z-,x+}}"
        else "x{components={x-,y+,x+}}"
    ]);
    burr_piece(spec);
    
}
