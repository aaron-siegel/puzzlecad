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

require_puzzlecad_version("2.0");

// The effective scale is 20 mm, but we use $burr_scale = 10 because
// we need to be able to join along half- and quarter-faces.

$burr_scale = 10;
$burr_bevel = 1.3;
$burr_inset = 0.07;
$plate_width = 120;

*pieces();
*tighter_key_piece();

module pieces() {

    burr_plate([
        ["....cc|..bbcc|aabb..|aa{connect=fy+z+,clabel=A}....", "....cc|..bbc{connect=fy+z+,clabel=B}c{connect=fy+z+,clabel=B}|aabb..|aa...."],
        ["xx|xx", "xx|x{connect=mz+y+,clabel=A}x"],
        ["xx|xx", "xx|x{connect=mz+y-,clabel=B}x{connect=mz+y-,clabel=B}"],
        ["....cc|..bbcc|a{connect=fy-z+,clabel=C}abb..|aa....", "....cc|..bbcc|aabb..|aa...."],
        ["xx|xx", "xx|x{connect=mz+y+,clabel=C}x"],
        ["aa..|aabb|..bb", "aa..|a{connect=fy+z+,clabel=D}a{connect=mz+y+,clabel=E}b{connect=mz+y+,clabel=E}b|..b{connect=mz+y+,clabel=E}b"],
        ["x{connect=fz-y+,clabel=E}x{connect=fz-y+,clabel=E}|xx{connect=fz-y+,clabel=E}", "xx|xx"],
        ["xx|xx{connect=fx+z+,clabel=F}", "xx|x{connect=mz+y-,clabel=D}x"],
        ["xx|xx", "xx|xx{connect=mz+y+,clabel=F}"],
        ["xx|xx", "xx|xx{connect=mz+y+,clabel=G}"],
        ["x{connect=fz-y+,clabel=G}x|xx", "xx|xx"]
    ]);

}

module tighter_key_piece() {
    
    burr_plate([
        ["xx|xx", "xx|xx{connect=mz+y+,clabel=G}"],
        ["x{connect=fz-y+,clabel=G}x|xx", "xx|xx"]
    ], $burr_inset = 0.01);
    
}
