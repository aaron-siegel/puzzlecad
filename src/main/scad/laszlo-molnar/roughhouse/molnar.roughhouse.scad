/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) László Molnár
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 14.5;
$burr_bevel = 2.0;

// Uncomment one of the following lines to render the appropriate component.

*pieces_1();
*pieces_2();

module pieces_1() {

    burr_plate([
        ["xxx{label_text=Roughhouse,label_orient=y-x-,label_hoffset=0.5}x|x...|x...", "...x|....|x{connect=mz+y+,clabel=A}...", "...x|....|...."],
        ["..x|xxx|.xx", "...|...|..x{connect=fz+y+,clabel=A}"],
        ["xxx{label_text=L. Molnár,label_orient=z+x-,label_hoffset=0.5}x|x..x|x...", "....|...x|x...", "....|...x{connect=fx-z+,clabel=B}|...."],
        ["x{connect=fz-x+,clabel=C}x{connect=mz+x-,clabel=B}"],
        ["xxx|x..", "..x{connect=mz+y+,clabel=C}|..."]
    ]);
    
}

module pieces_2() {

    burr_plate([
        ["...x|xxxx", "...x|x{connect=mz+y+,clabel=D}..x"],
        ["x{connect=fz-y+,clabel=D}.|x.|xx"],
        ["xxx|x{connect=mz+y-,clabel=E}x{connect=mz+y-,clabel=E}.|xx.", "xxx|...|xx."],
        ["xx{connect=fy-z+,clabel=E}x{connect=fy-z+,clabel=E}|x.."],
        ["xx|x."]
    ]);
    
}
