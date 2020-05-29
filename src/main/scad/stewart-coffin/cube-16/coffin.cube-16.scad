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

$burr_scale = 16;
$burr_inset = 0.07;
$burr_bevel = 1;

burr_plate([
    ["aa..|a{connect=mz+x-,clabel=A}abb|..bb"],
    ["x{connect=fx-z+,clabel=A}x|xx"],
    ["a{connect=mz+x-,clabel=B}a..|aabb", "....|..bb"],
    ["xx|x{connect=fx-z+,clabel=B}x"],
    ["xx|x{connect=mz+y+,clabel=C}x"],
    ["a..|abb{connect=fz-y+,clabel=C}|.bb", "a..|a..|..."],
    ["..aa|..a{label_text=Cube-16,label_orient=z+y-,label_hoffset=-0.5}a|bcc.|bcc.", "...d|...d|b...|b...", "...d|...d|....|...."],
    ["a..c|ab{label_text=#205,label_orient=z+x+,label_hoffset=0.5,label_voffset=0.1}bc|.b{label_text=STC,label_orient=z+x+,label_hoffset=0.5,label_voffset=-0.1}b.", "a..c|a..c|...."]
]);
