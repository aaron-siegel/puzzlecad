/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Yavuz Demirhan
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 12;
$burr_inset = 0.08;     // For a tighter fit, use $burr_inset = 0.06
$burr_bevel = 1;

// Uncomment one of the following lines to render that component.

*piece();
*alternate_piece();
*inscribed_piece();

module piece() {
    
    burr_piece("xxxx.|x..x.|x....|xxxxx");
    
}

module alternate_piece() {

    burr_piece("xxxx.|x....|x..x.|xxxxx");

}

module inscribed_piece() {
    
    burr_piece("xxx{label_text=Y. Demirhan,label_orient=z+x+,label_hoffset=-0.5,label_scale=0.4}x.|x..x.|x....|xxx{label_text=Knotty 6,label_orient=z+x+,label_hoffset=-0.5}xx");
    
}
