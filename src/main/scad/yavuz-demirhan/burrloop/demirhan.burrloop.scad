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
  3D model (c) Yu Chih Chang & Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 10;
$plate_width = 150;
$burr_inset = 0.07;     // Use 0.05 for a tighter fit

*frame();
*pieces();

module frame() {
    render(convexity = 2)
    burr_plate([
        ["x{connect=fx-z+,clabel=A}xxxx|x{connect=fx-z+,clabel=A}xxxx|...xx|...x{connect=mz+y-,clabel=B}x{connect=mz+y-,clabel=B}"],
        ["xxxxx{connect=fx+z+,clabel=B}|xxxxx{connect=fx+z+,clabel=B}|xx...|x{connect=mz+y-,clabel=A}x{connect=mz+y-,clabel=A}..."]
    ], num_copies = 3, $burr_bevel = 1);
}

module pieces() {
    burr_plate([
        ["xxxxxx|xxxxxx", "xxx..x|xxx..x"],
        ["xxx{label_text=Yavuz Demirhan,label_orient=z+x+,label_hoffset=0.5,label_voffset=0.15,label_scale=0.35}xxx|xxx{label_text=Burrloop,label_orient=z+x+,label_hoffset=0.5,label_voffset=-0.15}xxx", "x....x|x....x"],
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xx..xx|xxxxxx", "x....x|x....x"],
        ["xx..xx|xxxxxx", "x....x|x....x"]
    ], $burr_bevel = 0.5, $burr_outer_x_bevel = 1.75);
}
