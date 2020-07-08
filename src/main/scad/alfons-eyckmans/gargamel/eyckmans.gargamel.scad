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

$burr_scale = 10;
$burr_inset = 0.08;     // Use 0.07 for a tighter fit
$burr_bevel = 0.5;

*pieces_1();
*pieces_2();
*pieces_3();

module pieces_1() {

    burr_plate([
        [ "xxx{label_text=Gargamel,label_orient=y-x+,label_hoffset=0.5,label_voffset=-0.05}xxx|.x{connect=fx-z+,clabel=A}xxx{connect=fx+z+,clabel=B}.|xxxxxx" ],
        [ "xxxxxx|.x{connect=fx-z+,clabel=C}xxx{connect=fx+z+,clabel=D}.|xxxxxx" ],
        [ "xxxxxx|.x{connect=fx-z+,clabel=E}xxx{connect=fx+z+,clabel=F}.|xxxxxx" ],
        [ "xxxxxx|.x{connect=fx-z+,clabel=G}xxx{connect=fx+z+,clabel=H}.|xxxxxx" ],
        [ "x{connect=mz+x-,clabel=A}xxxxx{connect=mz+x+,clabel=C}", ".x...." ],
        [ "x{connect=mz+x-,clabel=B}xxxxx{connect=mz+x+,clabel=D}", "..xx.." ],
        [ "x{connect=mz+x-,clabel=E}xxxxx{connect=mz+x+,clabel=G}", "...x.." ],
        [ "x{connect=mz+x-,clabel=F}xxxxx{connect=mz+x+,clabel=H}", ".xx..." ],
    ]);

}

module pieces_2() {
    
    burr_plate([
        [ "xxxxxx|x....x|x....x", "xx..xx|x....x|x....x" ],
        [ "xxxxxx|x....x|x....x", "x...xx|x....x|x....x" ],
        [ "xxx{label_text=A. Eyckmans,label_orient=z+x-,label_hoffset=-0.5}xxx|x.x..x|x....x", "x....x|x....x|x....x" ],
        [ "xxxxxx|x..x.x|x....x", "x...xx|x....x|x....x" ]
    ], $burr_outer_x_bevel = 1.75);
    
}

module pieces_3() {
    
    burr_plate([
        [ "xxxxxx|x....x", "x....x|x....x" ],
        [ "xxxxxx|x...xx", "x....x|x...xx" ]
    ], $burr_outer_x_bevel = 1.75);

}
