/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Christoph Lohe
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.0");

// The effective scale is 20 mm, but we use $burr_scale = 10 because
// we need to be able to join along half- and quarter-faces.

$burr_scale = 10;
$burr_bevel = 1.3;
$burr_inset = 0.07;     // Use 0.06 for a tighter fit
$plate_width = 120;

burr_plate([

    // Piece S2
    ["..bb|aabb|aa..", "..bb|aab{connect=fy+z+,clabel=A}b{connect=fy+z+,clabel=A}|aa.."],
    ["xx|xx", "xx|x{connect=mz+y-,clabel=A}x{connect=mz+y-,clabel=A}"],

    // Piece S3
    ["aa..|aabb|..bb", "aa..|a{connect=fx-z+,clabel=B}abb{connect=fy-z+,clabel=C}|..bb"],
    ["xx|xx", "xx|xx{connect=mz+y-,clabel=B}"],
    ["x{connect=fy-z+,clabel=D}x|xx", "xx|x{connect=mz+y-,clabel=C}x"],
    ["xx|xx", "xx|x{connect=mz+y+,clabel=D}x"],

    // Piece S4
    ["aa..|aabb|..bb", "a{connect=fy-z+,clabel=E}a{connect=fy-z+,clabel=E}..|aabb|..bb{connect=mz+y+,clabel=F}"],
    ["xx|xx", "xx|x{connect=mz+y-,clabel=E}x{connect=mz+y-,clabel=E}"],
    ["x{connect=fy-z+,clabel=G}x|xx", "xx|x{connect=fz+y-,clabel=F}x"],
    ["xx|xx", "xx|x{connect=mz+y+,clabel=G}x"],

    // Piece S5
    ["..bb|aabb|aa..", "..bb{connect=mz+y+,clabel=H}|aabb{connect=fx+z+,clabel=J}|a{connect=fy+z+,clabel=K}a{connect=fy+z+,clabel=K}.."],
    ["xx|xx{connect=fx+z+,clabel=L}", "xx|x{connect=fz+x-,clabel=H}x"],
    ["xx|xx", "xx|x{connect=mz+y-,clabel=J}x"],
    ["xx|xx", "xx|x{connect=mz+y-,clabel=K}x{connect=mz+y-,clabel=K}"],
    ["xx|xx", "xx|xx{connect=mz+y+,clabel=L}"]
    
]);
