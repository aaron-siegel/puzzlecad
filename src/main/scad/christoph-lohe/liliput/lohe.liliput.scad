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

require_puzzlecad_version("2.1");

$burr_scale = 12;
$burr_inset = 0.09;
$burr_bevel = 0.5;

*frame();
*pieces();

module frame() {
    
    burr_plate([
        [ "xx{label_text=Christoph Lohe,label_orient=y-x+,label_hoffset=0.5,label_scale=0.35}xx|x.xx|x.xx|xxxx",
          "x.xx|....|....|x..x",
          "x..x{connect=fy+z+,clabel=B}|....|....|x..x",
          "x{connect=mz+y+,clabel=A}..x{connect=mz+y+,clabel=A}|....|....|x{connect=mz+y+,clabel=A}..x{connect=mz+y+,clabel=A}" ]
    ], $burr_bevel_adjustments = "z-o=1.75,z+=0.01");
    
    translate([4 * $burr_scale + $plate_sep, 0, 0])
    burr_plate([
        [ "x{connect=fz-y+,clabel=A}x{label_text=Liliput,label_orient=y-x+,label_hoffset=0.5,label_voffset=-0.1}xx{connect=fz-y+,clabel=A}|xx.x|xx.x|x{connect=fz-y+,clabel=A}xxx{connect=fz-y+,clabel=A}" ]
    ], $burr_bevel_adjustments = "z+o=1.75");
    
    translate([0, 4 * $burr_scale + $plate_sep, 0])
    burr_piece("x{connect=mz+y+,clabel=B}");
    
}

module pieces() {
    
    burr_plate([
        [ "x...|x..x{connect=mz+y+,clabel=C}|xxxx{connect=mz+y+,clabel=C}",
          "x...|....|x..." ],
        [ "x|x{connect=fz+y+,clabel=C}|x{connect=fz+y+,clabel=C}" ],
        [ "x...|xxxx{connect=mz+y+,clabel=D}|x...",
          "....|x...|...." ],
        [ "x|x{connect=fz+y+,clabel=D}|x" ],
    ]);
    
}
