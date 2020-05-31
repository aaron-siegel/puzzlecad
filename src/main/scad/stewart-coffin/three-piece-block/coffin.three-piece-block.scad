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

burr_plate([
    ["..bb|aabb{connect=fx+z+,clabel=A}|aa..", "..bb|aabb|aa.."],
    ["xx|xx", "xx|xx{connect=mz+y+,clabel=A}"],
    ["xx|xx", "x{connect=fx-z+,clabel=B}x|xx{connect=fy+z+,clabel=C}"],
    ["xx|xx", "xx|x{connect=mz+y-,clabel=B}x"],
    ["xx|xx", "xx|xx{connect=mz+y-,clabel=C}"],
    ["..bb|aabb|aa..", "..bb|aabb{connect=fx+z+,clabel=D}|a{connect=fy+z+,clabel=E}a{connect=fy+z+,clabel=E}.."],
    ["xx|xx", "xx|x{connect=mz+y-,clabel=D}x"],
    ["xx|xx", "xx|x{connect=mz+y-,clabel=E}x{connect=mz+y-,clabel=E}"],
]);
