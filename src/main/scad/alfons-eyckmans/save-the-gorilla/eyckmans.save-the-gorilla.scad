/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Alfons Eyckmans
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 9;
$burr_bevel = 0.5;
$burr_inset = 0.05;         // Use 0.04 for a tighter fit
gorilla_burr_inset = 0.08;  // Looser inset for the gorilla; use 0.07 for a tighter fit

*gorilla();
*pieces_color_1();
*pieces_color_2();
*pieces_color_3();

module pieces_color_1() {
    
    burr_plate([
        [ "xxxxxxxx|x....x.x", "xx....xx|x......x" ],
        [ "xxxxxxxx|x......x", "xx.x..xx|x......x" ],
        [ "xxxxxxxx|x....x.x", "xx....xx|x......x" ],
        [ "xxxxxxxx|x....x.x", "xx..x.xx|x......x" ],
        [ "xxxxxxxx|xx.....x", "x......x|x......x" ],
        [ "xxxxxxxx|x......x", "x....xxx|x......x" ],
    ], $burr_outer_x_bevel = 1.75);
   
}

module pieces_color_2() {
    
    burr_plate([
        [ "xxxxxxxx|x.x....x", "xx....xx|x......x" ],
        [ "xxxxxxxx|x....x.x", "xx....xx|x......x" ],
        [ "xxxxxxxx|x....x.x", "xx....xx|x......x" ],
        [ "xxxxxxxx|x......x", "x......x|x......x" ],
        [ "xxxx{label_text=Alfons Eyckmans,label_orient=z+x+,label_hoffset=0.5}xxxx|x..x...x", "x......x|x......x" ],
        [ "xxxxxxxx|x......x", "xx..xxxx|x......x" ],
    ], $burr_outer_x_bevel = 1.75);

}

module pieces_color_3() {
    
    burr_plate([
        [ "xxxxxxxx|x......x", "xx....xx|x......x" ],
        [ "xxxxxxxx{label_text=Save the Gorilla,label_orient=x+y-,label_hoffset=-2.5,label_voffset=-0.45,label_scale=0.5}|x......x", "xx....xx|x......x" ],
        [ "xxxxxxxx|x...x..x", "xx....xx|x......x" ],
        [ "x{label_text=Save the Gorilla,label_orient=x-y+,label_hoffset=2.5,label_voffset=-0.45,label_scale=0.5}xxxxxxx|x...x..x", "xx....xx|x......x" ],
        [ "xxxxxxxx|xx.x...x", "x......x|x......x" ],
        [ "xxxxxxxx{label_text=Save the Gorilla,label_orient=x+z+,label_hoffset=0.5,label_voffset=-0.45,label_scale=0.5}|x.x.x..x", "xx...x.x|x......x" ],
    ], $burr_outer_x_bevel = 1.75);
    
}

module gorilla() {

    burr_piece(".x.x.|.xxx.|..x..|xxxxx|x.x.x", $burr_inset = gorilla_burr_inset);
    
}
